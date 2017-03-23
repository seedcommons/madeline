class Admin::Accounting::TransactionsController < Admin::AdminController
  def index
    authorize :'accounting/transaction', :index?

    Accounting::Quickbooks::AccountFetcher.new.fetch
    Accounting::Quickbooks::TransactionFetcher.new.fetch

    @transactions = Accounting::Transaction.all
  rescue
    flash.now[:error] = "Error connecting to QuickBooks. Visit
      #{view_context.link_to('Settings', admin_settings_path)}.".html_safe
    @transactions = []
  end
end
