module TransactionControllable
  extend ActiveSupport::Concern

  def initialize_transactions_grid(project = nil)
    run_updater_and_handle_errors(project: project)

    @transactions = Accounting::Transaction
    @transactions = @transactions.where(project_id: project.id) if project
    @transactions = @transactions.includes(:account, :project, :currency, :line_items).standard_order

    check_if_qb_connected
    set_whether_add_txn_is_allowed
    set_whether_txn_list_is_visible

    @enable_export_to_csv = true
    @transactions_grid = initialize_grid(@transactions,
      enable_export_to_csv: @enable_export_to_csv,
      name: 'transactions'
    )
    export_grid_if_requested('transactions': 'admin/accounting/transactions/transactions_grid_definition')
  end

  def prep_transaction_form
    @loan_transaction_types = Accounting::Transaction.loan_transaction_type_options.select do |option|
      Accounting::Transaction::AVAILABLE_LOAN_TRANSACTION_TYPES.include?(option[1].to_sym)
    end
    @accounts = Accounting::Account.asset_accounts - Division.root.accounts
  end

  # Runs the given block and handles any Quickbooks errors.
  # Returns the error message (potentially with HTML) as a string if there was an error, else returns nil.
  # Notifies admins if error is not part of normal operation.
  # Sets the @full_sync_required variable if a FullSyncRequiredError error is raised.
  def handle_qb_errors
    begin
      yield
    rescue Accounting::Quickbooks::FullSyncRequiredError => e
      Rails.logger.error e
      @full_sync_required = true
      error_msg = t('quickbooks.full_sync_required', settings: settings_link).html_safe
    rescue Quickbooks::ServiceUnavailable => e
      Rails.logger.error e
      error_msg = t('quickbooks.service_unavailable')
    rescue Quickbooks::MissingRealmError,
      Accounting::Quickbooks::NotConnectedError,
      Quickbooks::AuthorizationFailure => e
      Rails.logger.error e
      error_msg = t('quickbooks.authorization_failure', settings: settings_link).html_safe
    rescue Quickbooks::InvalidModelException,
      Quickbooks::Forbidden,
      Quickbooks::ThrottleExceeded,
      Quickbooks::TooManyRequests,
      Quickbooks::IntuitRequestException => e
      Rails.logger.error e
      ExceptionNotifier.notify_exception(e)
      error_msg = t('quickbooks.misc', msg: e)
    end
    error_msg
  end

  def run_updater(project:)
    # Stub the Updater in test mode
    if Rails.env.test?
      # Raise an error if requested by the specs
      if msg = Rails.configuration.x.test.raise_qb_error_during_updater
        raise Quickbooks::InvalidModelException.new(msg)
      end
    else
      Accounting::Quickbooks::Updater.new.update(project)
    end
  end

  private

  def run_updater_and_handle_errors(project:)
    if error = handle_qb_errors { run_updater(project: project) }
      flash.now[:error] = error
    end
  end

  def set_whether_add_txn_is_allowed
    @add_transaction_available = Division.root.qb_accounts_connected? && !@full_sync_required
  end

  def set_whether_txn_list_is_visible
    @transaction_list_hidden = @full_sync_required || @transactions.count == 0
  end

  def check_if_qb_connected
    unless @add_transaction_available || flash.now[:error].present?
      flash.now[:alert] = t('quickbooks.not_connected', settings: settings_link).html_safe
    end
  end

  def settings_link
    view_context.link_to(t('menu.settings'), admin_settings_path)
  end
end
