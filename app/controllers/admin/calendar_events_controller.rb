class Admin::CalendarEventsController < Admin::AdminController
  def loan
    loan = Loan.find(params[:loan_id])
    authorize loan, :show?
    render_for_loan_filter(date_range(params), {id: loan.id})
  end

  # supports an explicitly specified division from the path info
  def division
    division = Division.find(params[:division_id])
    authorize division, :show?
    render_for_loan_filter(date_range(params), {division_id: division.id})
  end

  # this version honors the currently selected division
  def index
    skip_authorization
    # JE Todo: restore authorize when manage division branch merged
    # authorize Loan, :index?
    render_for_loan_filter(date_range(params), division_index_filter)
  end

  def render_for_loan_filter(date_range, filter)
    puts "loan filter: #{filter}, date range: #{date_range}" #JE Todo: remove

    # JE Todo: optimize this with db queries
    loans = LoanPolicy::Scope.new(current_user, Loan.where(filter)).resolve
    events = loans.reduce([]){ |list, loan| list.concat(loan_events(loan, render: false)) }
    puts "before select div event count: #{events.count}" #JE Todo: remove
    events.select!{ |event| date_range === event.start }
    puts "after select div event count: #{events.count}, first: #{events.first.inspect}" #JE Todo: remove
    events.each{ |event| event.html = render_event(event) }
    render json: events
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
