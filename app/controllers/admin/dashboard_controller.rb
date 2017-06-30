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

    @recent_projects_grid = initialize_wice_grid(@recent_projects, @person, 15)

    @status_filter_options = STATUS_FILTERS.map { |f| [I18n.t("dashboard.status_options.#{f}"), f] }
  end

  # Prepare grids for all users inside selected division
  def prep_projects_grids_for_division_users
    @people = @division.people.with_system_access.with_agent_projects.where.not(id: @person.id)

    @people_grids = {}
    @people.each do |person|
      projects = person.active_agent_projects
      @people_grids[person] = initialize_wice_grid(projects, person, 5)
    end
  end

  def prep_logs
    @context = "dashboard"
    @logs = ProjectLog.in_division(selected_division).where(agent_id: @person.id).by_date.page(1).per(10)
  end

  private

  def initialize_wice_grid(projects, person, page)
    initialize_grid(
        projects,
        include: [:primary_agent, :secondary_agent],
        per_page: page,
        order: 'projects.order_by_agent',
        custom_order: {
            'projects.order_by_agent' => "case when projects.primary_agent_id = #{person.id} and projects.status_value = 'active' and projects.type = 'Loan' then 8
                                               when projects.primary_agent_id = #{person.id} and projects.status_value = 'active' and projects.type = 'BasicProject' then 7
                                               when projects.primary_agent_id = #{person.id} and projects.status_value = 'prospective' and projects.type = 'Loan' then 6
                                               when projects.primary_agent_id = #{person.id} and projects.status_value = 'prospective' and projects.type = 'BasicProject' then 5
                                               when projects.secondary_agent_id = #{person.id} and projects.status_value = 'active' and projects.type = 'Loan' then 4
                                               when projects.secondary_agent_id = #{person.id} and projects.status_value = 'active' and projects.type = 'BasicProject' then 3
                                               when projects.secondary_agent_id = #{person.id} and projects.status_value = 'prospective' and projects.type = 'Loan' then 2
                                               when projects.secondary_agent_id = #{person.id} and projects.status_value = 'prospective' and projects.type = 'BasicProject' then 1
                                               else 0 end",
        },
        order_direction: 'desc',
        name: "projects_person_#{person.id}",
        enable_export_to_csv: false
    )
  end
end
