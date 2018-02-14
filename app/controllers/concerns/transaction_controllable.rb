module TransactionControllable
  extend ActiveSupport::Concern

  def initialize_transactions_grid(project = nil)
    run_updater_and_handle_errors(project: project)

    @transactions = Accounting::Transaction
    @transactions = @transactions.where(project_id: project.id) if project
    @transactions = @transactions.includes(:account, :project, :currency, :line_items).standard_order

    check_if_qb_accounts_selected
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
  # Sets the @data_reset_required variable if a DataResetRequiredError error is raised.
  def handle_qb_errors
    begin
      yield
    rescue Accounting::Quickbooks::DataResetRequiredError => e
      Rails.logger.error e
      @data_reset_required = true
      error_msg = t('quickbooks.data_reset_required', settings: settings_link).html_safe
    rescue Quickbooks::ServiceUnavailable => e
      Rails.logger.error e
      error_msg = t('quickbooks.service_unavailable')
    rescue Quickbooks::MissingRealmError,
      Accounting::Quickbooks::NotConnectedError,
      Quickbooks::AuthorizationFailure => e
      Rails.logger.error e
      @qb_not_connected = true
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
    @add_transaction_available = current_division.qb_division&.qb_accounts_selected? && !@data_reset_required
  end

  def set_whether_txn_list_is_visible
    @transaction_list_hidden = @qb_not_connected || @data_reset_required || @transactions.count == 0
  end

  def check_if_qb_accounts_selected
    unless current_division.qb_division&.qb_accounts_selected? || flash.now[:error].present?
      flash.now[:alert] = t('quickbooks.accounts_not_selected', settings: settings_link).html_safe
    end
  end

  def settings_link
    view_context.link_to(t('menu.accounting_settings'), admin_accounting_settings_path)
  end
end
