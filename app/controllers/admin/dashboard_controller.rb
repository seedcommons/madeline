class Admin::DashboardController < Admin::AdminController

  STATUS_FILTERS = %w(all active completed)

  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)
    @division = current_division

    prep_calendar
    prep_projects_grid
    prep_logs
    prep_projects_grids
  end

  private

  def prep_calendar
    @calendar_events_url = "/admin/calendar_events?person_id=#{@person.id}"
  end

  def prep_projects_grid
    # Projects belonging to the current user
    # 15 most recent projects, sorted by created date, then updated date
    @recent_projects = @person.agent_projects.order(created_at: :desc, updated_at: :desc).limit(15)

    @recent_projects_grid = initialize_grid(
      @recent_projects,
      include: [:primary_agent, :secondary_agent],
      per_page: 15,
      name: "recent_projects",
      enable_export_to_csv: false
    )

    @status_filter_options = STATUS_FILTERS.map { |f| [I18n.t("dashboard.status_options.#{f}"), f] }
  end

  # Prepare grids for all users inside selected division
  def prep_projects_grids
    @people = @division.people

    @people.each do |person|
      @projects_person_"#{person.id}" = person.agent_projects.order(created_at: :desc, updated_at: :desc).limit(15)

      @projects_grid_person_"#{person.id}" = initialize_grid(
        @projects_person_"#{person.id}",
        include: [:primary_agent, :secondary_agent],
        per_page: 15,
        name: "projects_person_#{person.id}",
        enable_export_to_csv: false
      )
    end
  end

  def prep_logs
    @context = "dashboard"
    @logs = ProjectLog.in_division(selected_division).where(agent_id: @person.id).by_date.page(1).
      per(10)
  end
end
