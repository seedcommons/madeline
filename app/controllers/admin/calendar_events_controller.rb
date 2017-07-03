class Admin::CalendarEventsController < Admin::AdminController

  # 'start' and 'end' ISO8601 formatted date params and always expected.
  # 'project_id' is optional and scopes to results for a single project if provided, otherwise all projects
  # within the current top nav division selection are included..
  def index
    # Calendar for a specific loan or basic project
    if params[:project_id]
      project = Project.find(params[:project_id])
      authorize project, :show?
      project_filter = {id: project.id}
    # Calendar on user dashboard
    elsif params[:person_id]
      person = Person.find(params[:person_id])
      skip_authorization
      project_filter = {id: policy_scope(person.agent_projects).pluck(:id)}
    # Main calendar, which shows all loans and basic projects in a division
    else
      skip_authorization
      # JE Todo: restore authorize when manage division branch merged
      # authorize Project, :index?
      project_filter = division_index_filter
    end
    render_for_project_filter(date_range(params), project_filter)
  end

  private

  def render_for_project_filter(date_range, project_filter)
    # JE Todo: Should theoretically apply project_step_scope scope here, but won't change results
    events = CalendarEvent.filtered_events(date_range: date_range, project_filter: project_filter,
      project_scope: policy_scope(Project), step_scope: ProjectStep, project_id: params[:project_id])
    events.each{ |event| event.html = render_event(event) }
    render json: events
  end

  def render_event(event)
    render_to_string(partial: "admin/calendar/event", locals: {cal_event: event}).html_safe
  end

  def date_range(params)
    start_date = date_param(params[:start], Date.today.beginning_of_month)
    end_date = date_param(params[:end], Date.today.end_of_month)
    start_date..end_date
  end

  def date_param(date_string, default = nil)
    date_string ? Date.iso8601(date_string) : default
  end

end
