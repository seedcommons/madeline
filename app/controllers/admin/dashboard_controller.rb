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
    @recent_projects = @person.active_agent_projects

    @recent_projects_grid = initialize_wice_grid(@recent_projects, @person.id, 15)

    @status_filter_options = STATUS_FILTERS.map { |f| [I18n.t("dashboard.status_options.#{f}"), f] }
  end

  # Prepare grids for all users inside selected division
  def prep_projects_grids_for_division_users
    @people = @division.people.with_system_access.with_agent_projects.where.not(id: @person.id)

    @people_grids = {}
    @people.each do |person|
      projects = person.active_agent_projects
      @people_grids[person] = initialize_wice_grid(projects, person.id, 5)
    end
  end

  def prep_logs
    @context = "dashboard"
    @logs = ProjectLog.in_division(selected_division).where(agent_id: @person.id).by_date.page(1).per(10)
  end

  private

  def initialize_wice_grid(projects, person_id, page)
    initialize_grid(
        projects,
        include: [:primary_agent, :secondary_agent],
        order: 'projects.order_by_agent',
        custom_order: {
            'projects.order_by_agent' => Project.dashboard_order(person_id),
        },
        name: "projects_person_#{person_id}",
        enable_export_to_csv: false
    )
  end
end
