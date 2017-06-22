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
      journal_entry = creator.add_disbursement @transaction

      # It's important we store the ID and type of the QB journal entry we just created
      # so that on the next sync, a duplicate is not created.
      @transaction.associate_with_qb_obj(journal_entry)

      @transaction.save!
      flash[:notice] = t("admin.loans.transactions.create_success")
      render nothing: true
    rescue => ex
      # We don't need to display the message twice if it's a validation error.
      # But we do want to display the error if the QB API blows up.
      @transaction.errors.add(:base, ex.message) unless ex.is_a?(ActiveRecord::RecordInvalid)
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
