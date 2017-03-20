class Admin::DashboardController < Admin::AdminController

  STATUS_FILTERS = %w(all active completed)

  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)
    @division = current_division

    prep_calendar
    prep_projects_grid_for_current_user
    prep_logs
    prep_projects_grids_for_division_users
  end

  private

  def prep_calendar
    @calendar_events_url = "/admin/calendar_events?person_id=#{@person.id}"
  end

  def prep_projects_grid_for_current_user
    # Projects belonging to the current user
    # 15 most recent projects, sorted by created date, then updated date
    @recent_projects = @person.agent_projects.order(created_at: :desc, updated_at: :desc)

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
  def prep_projects_grids_for_division_users
    people = @division.people.with_system_access.where.not(id: @person.id)

    @people = []
    @people_grids = {}
    people.each do |person|
      if person.agent_projects.length > 0
        @people << person
        @people_grids["#{person}"] = initialize_grid(
          person.agent_projects.order(created_at: :desc, updated_at: :desc),
          include: [:primary_agent, :secondary_agent],
          per_page: 5,
          name: "projects_person_#{person.id}",
          enable_export_to_csv: false
        )
      end
    end
  end

  def prep_logs
    @context = "dashboard"
    @logs = ProjectLog.in_division(selected_division).where(agent_id: @person.id).by_date.page(1).
      per(10)
  end
end
