class Admin::Accounting::TransactionsController < Admin::AdminController
  def index
    authorize :'accounting/transaction', :index?

    begin
      ::Accounting::Quickbooks::AccountFetcher.new.fetch
      ::Accounting::Quickbooks::TransactionFetcher.new.fetch
    rescue Accounting::Quickbooks::FetchError => e
      Rails.logger.error e
      Rails.logger.error e.cause
      flash.now[:error] = 'Error connecting to quickbooks'
    end

    @transactions = ::Accounting::Transaction.all
    @transactions_grid = initialize_grid(@transactions)
  end
end
