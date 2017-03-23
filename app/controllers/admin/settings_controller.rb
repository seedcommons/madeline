class Admin::SettingsController < Admin::AdminController

  def index
    authorize :setting, :index?

    @division = current_division.root
  end

end
