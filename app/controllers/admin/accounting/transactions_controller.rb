class Admin::Accounting::TransactionsController < Admin::AdminController
  include TransactionListable

  def index
    authorize :'accounting/transaction', :index?

    initialize_transactions_grid
  end

  def new
    @loan = Loan.find_by(id: params[:project_id])
    @transaction = ::Accounting::Transaction.new(project_id: params[:project_id])
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
    authorize @loan
    @transaction = ::Accounting::Transaction.new(transaction_params)

    begin
      raise ActiveRecord::RecordInvalid.new(@transaction) if !@transaction.valid?

      # We don't have the ability to stub quickbooks interactions so
      # for now we'll just return a fake JournalEntry in test mode.
      if Rails.env.test?
        journal_entry = Quickbooks::Model::JournalEntry.new(id: 123)
      else
        creator = ::Accounting::Quickbooks::TransactionCreator.new
        journal_entry = creator.create_in_qb @transaction
      end

      # It's important we store the ID and type of the QB journal entry we just created
      # so that on the next sync, a duplicate is not created.
      @transaction.associate_with_qb_obj(journal_entry)
      @transaction.save!

      # Create blank interest transaction. The interest calculator will pick this up and
      # calculate the value, and sync it to quickbooks.
      interest_description = I18n.t('transactions.interest_description', loan_id: @loan.id)

      interest_transaction = ::Accounting::Transaction
        .find_or_create_by!(transaction_params.except(:amount, :description)
        .merge(qb_transaction_type: ::Accounting::Transaction::LOAN_INTEREST_TYPE, description: interest_description))

      flash[:notice] = t("admin.loans.transactions.create_success")
      render nothing: true
    rescue => ex
      # We don't need to display the message twice if it's a validation error.
      # But we do want to display the error if the QB API blows up.
      if ex.is_a?(ActiveRecord::RecordInvalid)
        # Only raise error if we had a problem saving the interest transaction
        raise ex if ex.record == interest_transaction
      elsif ex.class.name.include?('Quickbooks::')
        @transaction.errors.add(:base, ex.message)
      else
        raise ex
      end

      prep_transaction_form
      render_modal_partial(status: 422)
    end
  end

  def update
    @transaction = ::Accounting::Transaction.find_by(id: params[:id])
    @loan = Loan.find_by(id: @transaction.project_id)
    authorize @transaction, :update?

    if @transaction.save
      redirect_to admin_loan_tab_path(@loan.id, tab: 'transactions'), notice: I18n.t(:notice_updated)
    else
      prep_transaction_form
      render_modal_partial
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
