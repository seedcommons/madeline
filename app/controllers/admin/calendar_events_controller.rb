class Admin::CalendarEventsController < Admin::AdminController

  # 'start' and 'end' ISO8601 formatted date params and always expected.
  # 'project_id' is optional and scopes to results to a single loan if provided, otherwise all loans
  # within the current top nav division selection are included..
  def index
    if params[:project_id]
      loan = Loan.find(params[:project_id])
      authorize loan, :show?
      loan_filter = {id: loan.id}
    else
      skip_authorization
      # JE Todo: restore authorize when manage division branch merged
      # authorize Loan, :index?
      loan_filter = division_index_filter
    end
    render_for_loan_filter(date_range(params), loan_filter)
  end

  private

  def render_for_loan_filter(date_range, loan_filter)
    # JE Todo: Should theoretically apply project_step_scope scope here, but won't change results
    events = CalendarEvent.filtered_events(date_range: date_range, loan_filter: loan_filter,
      loan_scope: loan_policy_scope(Loan), step_scope: ProjectStep)
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
