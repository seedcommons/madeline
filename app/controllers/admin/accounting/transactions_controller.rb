class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionListable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end
end
