class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionListable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def new
  end

  def create
    @loan = Loan.find(transaction_params[:loan_id])
    authorize @loan
    @transaction = ::Accounting::Transaction.new(project: @loan)

    begin
      creator = ::Accounting::Quickbooks::TransactionCreator.new
      creator.add_disbursement(
        amount: transaction_params[:amount],
        loan_id: transaction_params[:loan_id],
        description: '',
        memo: transaction_params[:private_note],
        qb_bank_account_id:  transaction_params[:qb_bank_account_id],
        organization: @loan.organization,
      )

      render_modal_partial
    rescue => ex
      flash.now[:error] = ex.message
      render_modal_partial(status: 422)
    end
  end

  private

  def transaction_params
    params.require(:accounting_transaction).permit(:loan_id, :qb_bank_account_id, :amount, :private_note)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end
end
