module TransactionListable
  extend ActiveSupport::Concern

  def initialize_transactions_grid(project_id: nil)
    begin
      ::Accounting::Quickbooks::AccountFetcher.new.fetch
      ::Accounting::Quickbooks::TransactionFetcher.new.fetch
    rescue Accounting::Quickbooks::FetchError => e
      Rails.logger.error e
      Rails.logger.error e.cause
      flash.now[:error] = 'Error connecting to quickbooks'
    end

    if project_id
      @transactions = ::Accounting::Transaction.where(project_id: project_id)
    else
      @transactions = ::Accounting::Transaction.all
    end

    @transactions_grid = initialize_grid(@transactions)
  end
end
