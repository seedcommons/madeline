class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionListable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def create
    @loan = Loan.find(transaction_params[:project_id])
    authorize @loan
    @transaction = ::Accounting::Transaction.new(transaction_params)

    begin
      creator = ::Accounting::Quickbooks::TransactionCreator.new
      creator.add_disbursement @transaction

      render_modal_partial
    rescue => ex
      @transaction.errors.add(:base, ex.message)
      render_modal_partial(status: 422)
    end
  end

  private

  def transaction_params
    params.require(:accounting_transaction).permit(:project_id, :account_id, :amount, :private_note, :accounting_account_id, :description)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end
end
