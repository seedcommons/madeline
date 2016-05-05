class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans

    authorize @division

    #JE Todo: rename with snakecase
    @calEvents = []

    @loans.each do |loan|
      @calEvents.concat( loan_events(loan) )
    end

  end

  # TODO: Move to reusable concern
  def prepare_event(cal_event)
    content = render_to_string(partial: "admin/calendar/event", locals: {cal_event: cal_event}).html_safe
    cal_event[:title] = content
    @calEvents.push(cal_event)
  end
end
