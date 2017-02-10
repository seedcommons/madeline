class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize Project
    authorize Person
    @person = Person.find(current_user.profile_id)

    # Projects belonging to the current user, 15 most recent
    @recent_projects = @person.agent_projects
  end
end
