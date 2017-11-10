class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionListable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def create
    @loan = Loan.find(transaction_params[:project_id])
    authorize(@loan, :update?)
    @transaction = ::Accounting::Transaction.new(transaction_params.merge qb_transaction_type: 'JournalEntry')

    # If earlier transactions exist, but no interest transaction on this date, create a blank one.
    # The InterestCalculator will pick this up, calculate the value, and sync it to quickbooks.
    if @loan.transactions.where('txn_date < ?', transaction_params[:txn_date]).exists?
      attrs = transaction_params.slice(:txn_date).merge(loan_transaction_type_value: 'interest')
      interest_transaction = @loan.transactions.find_or_create_by!(attrs) do |txn|
        txn.qb_transaction_type = ::Accounting::Transaction::LOAN_INTEREST_TYPE
        txn.description = I18n.t('transactions.interest_description', loan_id: @loan.id)
        txn.amount = 0
      end
    end

    if @transaction.save
      flash[:notice] = t("admin.loans.transactions.create_success")
      render nothing: true
    else
      prep_transaction_form
      render_modal_partial(status: 422)
    end
  rescue => ex
    # Display QB error as validation error on form
    if ex.class.name.include?('Quickbooks::')
      @transaction.errors.add(:base, ex.message)
      prep_transaction_form
      render_modal_partial(status: 422)
    else
      raise ex
    end
  end

  private

  def transaction_params
    params.require(:accounting_transaction).permit(:project_id, :account_id, :amount,
      :private_note, :accounting_account_id, :description, :txn_date, :loan_transaction_type_value)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end
end
