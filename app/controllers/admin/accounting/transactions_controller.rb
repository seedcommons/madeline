class Admin::Accounting::TransactionsController < Admin::AdminController
  def index
    authorize :'accounting/transaction', :index?

    Accounting::Quickbooks::AccountFetcher.new.fetch
    Accounting::Quickbooks::TransactionFetcher.new.fetch

    @transactions = Accounting::Transaction.all
  rescue
    flash.now[:error] = 'Error connecting to quickbooks'
    @transactions = []
  end
end
