class Admin::Accounting::TransactionsController < Admin::AdminController
  def index
    authorize :'accounting/transaction', :index?

    @transactions = Accounting::Transaction.all.with_qb_objects
  end

  private

  def auth_details
    { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }
  end

  def qb_connection
    @qb_connection ||= Division.root.qb_connection
  end
end
