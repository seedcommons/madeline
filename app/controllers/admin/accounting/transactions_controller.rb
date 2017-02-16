class Admin::Accounting::TransactionsController < Admin::AdminController
  def index
    authorize :'accounting/transaction', :index?

    # This is temporary code until the proper transaction wrappers are created.
    @transaction_list = %w(JournalEntry Deposit Purchase).map do |transaction_type|
      transactions = Quickbooks::Service.const_get(transaction_type).new(auth_details).query
      transactions.map do |t|
        {
          type: transaction_type,
          id: t.id,
          txn_date: t.txn_date,
          total: t.total,
          private_note: t.private_note,
        }
      end
    end.flatten.sort_by{ |t| t[:txn_date] }
  end

  private

  def auth_details
    { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }
  end

  def qb_connection
    @qb_connection ||= Division.root.qb_connection
  end
end
