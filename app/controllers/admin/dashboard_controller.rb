class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize Project
    authorize Person
    @person = Person.find(current_user.profile_id)

    # Projects belonging to the current user
    # 15 most recent projects, sorted by created date, then updated date
    @recent_projects = @person.agent_projects.order(created_at: :desc, updated_at: :desc).limit(15)

    @recent_projects_grid = initialize_grid(
      @recent_projects,
      include: [:primary_agent, :secondary_agent],
      per_page: 15,
      name: "recent_projects",
      enable_export_to_csv: true
    )

    @csv_mode = true
    export_grid_if_requested(recent_projects: "recent_projects_grid_definition") do
      # The below only executes if CSV is not being returned
      @csv_mode = false
    end
  end
end
