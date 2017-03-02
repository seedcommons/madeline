class Admin::DashboardController < Admin::AdminController

  STATUS_FILTERS = %w(all active completed)

  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)

    prep_calendar
    prep_projects_grid
  end

  private

  def prep_calendar
    @division = current_division
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

    @status_filter_options = status_filter_options
  end

  def status_filter_options
    filter_options = []
    STATUS_FILTERS.each do |item|
        filter_options.push([I18n.t("dashboard.status_options.#{item}"), item])
    end
    return filter_options
  end
end
