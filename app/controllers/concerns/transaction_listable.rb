module TransactionListable
  extend ActiveSupport::Concern

  def initialize_transactions_grid(project_id = nil)
    update_transactions if Division.root.quickbooks_connected?
    @add_transaction_available = Division.root.qb_accounts_connected?

    if project_id
      @transactions = ::Accounting::Transaction.where(project_id: project_id)
    else
      @transactions = ::Accounting::Transaction.all
    end

    @transactions = @transactions.includes(:account, :project, :currency, :line_items).standard_order

    @enable_export_to_csv = true

    @transactions_grid = initialize_grid(@transactions,
      enable_export_to_csv: @enable_export_to_csv,
      name: 'transactions'
    )

    unless @add_transaction_available || flash.now[:error].present?
      # We need to use the view helper version of `t` so that we can use the _html functionality.
      flash.now[:alert] = self.class.helpers.t('quickbooks.not_connected_html',
        link: admin_settings_url)
    end

    @transaction_list_hidden = @full_sync_required

    export_grid_if_requested('transactions': 'admin/accounting/transactions/transactions_grid_definition')
  end

  def prep_transaction_form
    @loan_transaction_types = Accounting::Transaction.loan_transaction_type_options.select do |option|
      Accounting::Transaction::AVAILABLE_LOAN_TRANSACTION_TYPES.include?(option[1].to_sym)
    end
    @accounts = Accounting::Account.asset_accounts - Division.root.accounts
  end

  private

  def update_transactions
    ::Accounting::Quickbooks::Updater.new.update
  rescue Accounting::Quickbooks::FullSyncRequiredError => e
    Rails.logger.error e
    @full_sync_required = true
    settings = view_context.link_to(t('menu.settings'), admin_settings_path)
    flash.now[:error] = t('quickbooks.full_sync_required', settings: settings).html_safe
  rescue Quickbooks::ServiceUnavailable => e
    Rails.logger.error e
    flash.now[:error] = t('quickbooks.service_unavailable')
  rescue Quickbooks::MissingRealmError,
    Accounting::Quickbooks::NotConnectedError,
    Quickbooks::AuthorizationFailure => e
    Rails.logger.error e
    settings = view_context.link_to(t('menu.settings'), admin_settings_path)
    flash.now[:error] = t('quickbooks.authorization_failure', settings: settings, target: "_blank").html_safe
  rescue Quickbooks::InvalidModelException,
    Quickbooks::Forbidden,
    Quickbooks::ThrottleExceeded,
    Quickbooks::TooManyRequests,
    Quickbooks::IntuitRequestException => e
    Rails.logger.error e
    ExceptionNotifier.notify_exception(e)
    flash.now[:error] = t('quickbooks.misc')
  end
end
