class Admin::TransactionsController < Admin::AdminController

  def index
    authorize :transaction, :index?

    auth_details = {access_token: Division.connector.access_token, company_id: Division.connector.realm_id}

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
end
