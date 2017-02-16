class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)
  end
end
