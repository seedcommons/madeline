class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionControllable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def new
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = Accounting::Transaction.new(project_id: params[:project_id])
    authorize @transaction, :new?

    prep_transaction_form
    render_modal_partial
  end

  def show
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = Accounting::Transaction.find_by(id: params[:id])
    authorize @transaction, :show?

    prep_transaction_form
    render_modal_partial
  end

  def create
    @loan = Loan.find(transaction_params[:project_id])
    authorize @loan
    @transaction = Accounting::Transaction.new(transaction_params)

    if @transaction.valid?
      # This is a database transaction, not accounting!
      # We use it because we want to rollback transaction creation or updates if there are errors.
      ActiveRecord::Base.transaction do
        reconcile_and_save_transaction
        ensure_interest_transaction
        if error = run_updater_and_handle_errors(project: @transaction.project)
          @transaction.errors.add(:base, error)
          raise ActiveRecord::Rollback
        end
      end
    end

    # Since the txn has already been saved and/or validated before errors are added after
    # run_updater_and_handle_errors, valid? may be true even if there are errors.
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

  # Syncs transaction to Quickbooks, saves the new QB ID, and saves the transaction.
  # Assumes @transaction has already been validated.
  # Raises ActiveRecord::InvalidRecord if somehow the txn becomes invalid (shouldn't happen).
  # May raise Quickbooks errors due to the sync operation.
  def reconcile_and_save_transaction
    # We don't have the ability to stub quickbooks interactions so
    # for now we'll just return a fake JournalEntry in test mode.
    if Rails.env.test?
      journal_entry = Quickbooks::Model::JournalEntry.new(id: rand(1000000000))
    else
      reconciler = Accounting::Quickbooks::TransactionReconciler.new
      journal_entry = reconciler.reconcile(@transaction)
    end

    # It's important we store the ID and type of the QB journal entry we just created
    # so that on the next sync, a duplicate is not created.
    @transaction.associate_with_qb_obj(journal_entry)
    @transaction.save!
  end

  # Create blank interest transaction. The interest calculator will pick this up and
  # calculate the value, and sync it to quickbooks.
  # Raises an ActiveRecord::InvalidRecord error if there is a validation error, which there never should be.
  def ensure_interest_transaction
    Accounting::Transaction.find_or_create_by!(transaction_params.except(:amount, :description).merge(
      qb_transaction_type: Accounting::Transaction::LOAN_INTEREST_TYPE,
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
