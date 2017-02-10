class Admin::DashboardController < Admin::AdminController
  def dashboard
    skip_authorization
  end
end
