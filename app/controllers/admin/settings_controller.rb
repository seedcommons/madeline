class Admin::SettingsController < Admin::AdminController

  def index
    authorize :setting, :index?

    @division = current_division.root
    @accounts = ::Accounting::Account.all.map{|account| [account.name, account.qb_id] }
  end
end
