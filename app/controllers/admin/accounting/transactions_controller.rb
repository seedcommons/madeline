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
      raise ActiveRecord::RecordInvalid.new(@transaction) if !@transaction.valid?

      # We don't have the ability to stub quickbooks interactions so
      # for now we'll just return a fake JournalEntry in test mode.
      if Rails.env.test?
        journal_entry = Quickbooks::Model::JournalEntry.new(id: 123)
      else
        creator = ::Accounting::Quickbooks::TransactionCreator.new
        journal_entry = creator.add_disbursement @transaction
      end

      # It's important we store the ID and type of the QB journal entry we just created
      # so that on the next sync, a duplicate is not created.
      @transaction.associate_with_qb_obj(journal_entry)

      @transaction.save!
      flash[:notice] = t("admin.loans.transactions.create_success")
      render nothing: true
    rescue => ex
      # We don't need to display the message twice if it's a validation error.
      # But we do want to display the error if the QB API blows up.
      if ex.is_a?(ActiveRecord::RecordInvalid)
        # Do nothing
      elsif ex.class.name.include?('Quickbooks::')
        @transaction.errors.add(:base, ex.message)
      else
        raise ex
      end
      @loan_transaction_types = ::Accounting::Transaction::LOAN_TRANSACTION_TYPES
      @accounts = Accounting::Account.where(qb_account_classification: 'Asset') - Division.root.accounts
      render_modal_partial(status: 422)
    end
  end

  private

  def transaction_params
    params.require(:accounting_transaction).permit(:project_id, :account_id, :amount,
      :private_note, :accounting_account_id, :description, :txn_date, :loan_transaction_type)
  end

  def render_modal_partial(status: 200)
    render partial: "admin/accounting/transactions/modal_content", status: status
  end
end
