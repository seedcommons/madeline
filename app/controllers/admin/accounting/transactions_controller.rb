class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionControllable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def new
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = Accounting::Transaction.new(project_id: params[:project_id], txn_date: Date.today)
    authorize @transaction, :new?

    prep_transaction_form
    render_modal_partial
  end

  def show
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = ::Accounting::Transaction.find_by(id: params[:id])
    authorize @transaction, :show?

    prep_transaction_form
    render_modal_partial
  end

  def create
    @loan = Loan.find(transaction_params[:project_id])
    authorize(@loan, :update?)
    @transaction = ::Accounting::Transaction.new(transaction_params)
    process_transaction_and_handle_errors

    # Since the txn has already been saved and/or validated before qb errors are added,
    # valid? may be true even if there are errors.
    if @transaction.errors.any?
      prep_transaction_form
      render_modal_partial(status: 422)
    else
      # The JS modal view will reload the index page if we return 200, so we set a flash message.
      flash[:notice] = t("admin.loans.transactions.create_success")
      head :ok
    end
  end

  private

  # Saves transaction record, creates interest transaction, runs updater.
  # Does nothing if transaction is invalid.
  # Handles any QB errors that come up in updater and sets them as base errors on @transaction.
  def process_transaction_and_handle_errors
    return unless @transaction.valid?

    # This is a database transaction, not accounting!
    # We use it because we want to rollback transaction creation or updates if there are errors.
    ActiveRecord::Base.transaction do
      @transaction.save!
      ensure_interest_transaction

      if error = handle_qb_errors { run_updater(project: @transaction.project) }
        @transaction.errors.add(:base, error)
        raise ActiveRecord::Rollback
      end
    end
  end

  # Create blank interest transaction. The interest calculator will pick this up and
  # calculate the value, and sync it to quickbooks.
  # Raises an ActiveRecord::InvalidRecord error if there is a validation error, which there never should be.
  def ensure_interest_transaction
    Accounting::Transaction.find_or_create_by!(transaction_params.merge(
      loan_transaction_type_value: Accounting::Transaction::LOAN_INTEREST_TYPE,
      amount: 0, # This is a temporary value.
      description: I18n.t('transactions.interest_description', loan_id: @loan.id)
    ))
  end

  def transaction_params
    params.require(:accounting_transaction).permit(:project_id, :account_id, :amount,
      :private_note, :accounting_account_id, :description, :txn_date, :loan_transaction_type_value)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end
end
