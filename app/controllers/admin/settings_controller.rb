class Admin::SettingsController < Admin::AdminController

  def index
    authorize :setting

    @division = current_division.root
    @accounts = ::Accounting::Account.all if @division.quickbooks_connected?
    @last_updated_at = @division.qb_connection.last_updated_at if @division.quickbooks_connected?
  end

  def update
    authorize :setting

    @division = current_division.root
    if @division.update(settings_params)
      redirect_to admin_settings_path, notice: I18n.t(:notice_updated)
    else
      @accounts = ::Accounting::Account.all if @division.quickbooks_connected?
      render :index
    end
  end

  def settings_params
    params.require(:division).permit(:principal_account_id, :interest_receivable_account_id,
      :interest_income_account_id)
  end
end
