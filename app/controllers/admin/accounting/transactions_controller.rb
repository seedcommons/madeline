class Admin::Accounting::TransactionsController < Admin::AdminController
  def new
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = ::Accounting::Transaction.new(project: @loan, txn_date: Time.zone.today, managed: true)
    authorize(@transaction, :new?)
    prep_transaction_form
    render_modal_partial
  end

  def show
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = ::Accounting::Transaction.find_by(id: params[:id])
    authorize(@transaction, :show?)
    prep_transaction_form
    render_modal_partial
  end

  def sync
    @loan = Loan.find(params[:project_id])
    @transaction = ::Accounting::Transaction.new(project: @loan, txn_date: Time.zone.today)
    authorize(@transaction, :show?)
    sync_and_handle_errors
    redirect_to(admin_loan_tab_path(@loan, tab: "transactions"))
  end

  def create
    @transaction = ::Accounting::Transaction.new(
      transaction_params.merge(project_id: params[:project_id], managed: true)
    )
    authorize(@transaction, :create?)
    @loan = @transaction.project
    @transaction.user_created = true
    @transaction.managed = true
    @transaction.currency_id = @loan.currency_id
    process_transaction_and_handle_errors

    # Since the txn has already been saved and/or validated before qb errors are added,
    # valid? may be true even if there are errors.
    if @transaction.errors.any?
      prep_transaction_form
      render_modal_partial(status: 422)
    else
      # The JS modal view will reload the index page if we return 200, so we set a flash message.
      flash[:notice] = t("admin.loans.transactions.create_success")
      head :ok
    end
  end

  def update
    @transaction = ::Accounting::Transaction.find_by(id: params[:id])
    authorize(@transaction, :update?)
    @loan = @transaction.project
    @transaction.attributes = transaction_params

    # Treat this like a new transaction
    @transaction.user_created = true
    @transaction.quickbooks_data = nil
    @transaction.line_items.destroy_all
    @transaction.needs_qb_push = true
    process_transaction_and_handle_errors

    if @transaction.errors.any?
      prep_transaction_form
      render_modal_partial(status: 422)
    else
      # The JS modal view will reload the index page if we return 200, so we set a flash message.
      flash[:notice] = t("admin.loans.transactions.update_success")
      head :ok
    end
  end

  private

  # Saves transaction record and runs updater.
  # Does nothing if transaction is invalid.
  # Handles any QB errors that come up in updater and sets them as base errors on @transaction.
  def process_transaction_and_handle_errors
    # This is a database transaction, not accounting!
    # We use it because we want to rollback transaction creation or updates if there are errors.
    ActiveRecord::Base.transaction do
      if @transaction.save
        if (error_msg = handle_qb_errors { run_updater(project: @transaction.project) })
          @transaction.errors.add(:base, error_msg)
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def sync_and_handle_errors
    ActiveRecord::Base.transaction do
      if (error_msg = handle_qb_errors { run_updater(project: @loan) })
        flash[:error] = error_msg
        raise ActiveRecord::Rollback
      end
      flash[:notice] = t("admin.loans.transactions.sync_complete")
    end
  end

  def transaction_params
    # We don't permit project_id because that's a privilege escalation issue. For update, it should
    # already be set and can't be changed. For create, we get it from the query string manually.
    params.require(:accounting_transaction).permit(:account_id, :amount,
                                                   :private_note, :accounting_account_id, :description, :txn_date, :loan_transaction_type_value,
                                                   :accounting_customer_id, :qb_vendor_id, :disbursement_type, :check_number)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end

  def prep_transaction_form
    @loan_transaction_types = Accounting::Transaction.loan_transaction_type_options.select do |option|
      Accounting::Transaction::AVAILABLE_LOAN_TRANSACTION_TYPES.include?(option[1].to_sym)
    end
    @disbursement_types = Accounting::Transaction::DISBURSEMENT_TYPES.map do |t|
      [I18n.t("transactions.disbursement_type.#{t}"), t]
    end
    @accounts = Accounting::Account.asset_accounts - Division.root.accounts
    @customers = Accounting::Customer.all.order(:name)
    @vendors = Accounting::QB::Vendor.all.order(:name)
  end

  # Runs the given block and handles any Quickbooks errors.
  # Returns the error message (potentially with HTML) as a string if there was an error, else returns nil.
  # Notifies admins if error is not part of normal operation.
  # This is only used for creating new transactions
  def handle_qb_errors
    begin
      yield
    rescue Accounting::QB::DataResetRequiredError => e
      Rails.logger.error e
      error_msg = t("quickbooks.data_reset_required", settings: settings_link).html_safe
    rescue Accounting::QB::UnprocessableAccountError => e
      # Duplicated in QuickbooksUpdateJob, should be DRYed up in refactor.
      Accounting::SyncIssue.create!(loan: e.loan, accounting_transaction: e.transaction,
                                    message: :unprocessable_account, level: :error, custom_data: {})
    rescue Accounting::QB::IntuitRequestError => e
      # TODO: duplicate in QuickbooksUpdateJob, then should be DRYed up in refactor.
      txn = e.transaction
      is_matching_error = e.message.include?("matched to a downloaded transaction")
      intuit_error_type = is_matching_error ? :matched_transaction : :unknown_intuit_request_exception
      Accounting::SyncIssue.create!(loan: txn.loan,
                                    accounting_transaction: txn,
                                    message: intuit_error_type,
                                    level: :warning, # want to still see ledger
                                    custom_data: {date: txn.txn_date, qb_id: txn.qb_id},
                                    # hacking quickbooks_data field here
                                    # TODO: quickbooks_data needs to be generalized to e.g. debug_data
                                    quickbooks_data: {
                                      txn_changes: txn.previous_changes,
                                      line_item_changes: txn.line_items.map { |li| li.previous_changes }
                                    })
      error_msg = t("quickbooks.#{intuit_error_type}",
                    txn_date: txn.txn_date,
                    qb_id: txn.qb_id)
    rescue Quickbooks::ServiceUnavailable => e
      Rails.logger.error e
      error_msg = t("quickbooks.service_unavailable")
    rescue Quickbooks::MissingRealmError,
           Accounting::QB::NotConnectedError,
           Quickbooks::AuthorizationFailure => e
      Rails.logger.error e
      error_msg = t("quickbooks.authorization_failure", settings: settings_link).html_safe
    rescue Quickbooks::InvalidModelException,
           Quickbooks::Forbidden,
           Quickbooks::ThrottleExceeded,
           Quickbooks::TooManyRequests,
           Quickbooks::IntuitRequestException => e
      Rails.logger.error e
      ExceptionNotifier.notify_exception(e)
      error_msg = t("quickbooks.misc", msg: e)
    rescue Accounting::QB::NegativeBalanceError => e
      Rails.logger.error e
      error_msg = t("quickbooks.negative_balance", amt: e.prev_balance)
    end
    error_msg
  end

  def run_updater(project:)
    # Stub the Updater in test mode
    if Rails.env.test?
      raise Quickbooks::ServiceUnavailable if ENV.key?("RAISE_QB_ERROR_DURING_UPDATER")
    else
      Accounting::QB::Updater.new.update(project)
    end
  end

  def settings_link
    view_context.link_to(t("menu.accounting_settings"), admin_accounting_settings_path)
  end
end
