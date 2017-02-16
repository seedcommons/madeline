class Admin::SettingsController < Admin::AdminController

  def index
    authorize :setting, :index?
  end

end
