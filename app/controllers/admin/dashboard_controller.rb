class Admin::DashboardController < Admin::AdminController
  def index
    authorize :dashboard, :index?
  end
end
