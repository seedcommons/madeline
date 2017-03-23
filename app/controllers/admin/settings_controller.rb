class Admin::SettingsController < Admin::AdminController

  def index
    authorize :setting, :index?

    @division = current_division.root
    # @accounts = Accounting::Account.all
    @accounts = Accounting::Transaction.where(qb_transaction_type: 'Account').map{|account| [account.quickbooks_data[:name], account.quickbooks_data[:id]] }
  end

end
