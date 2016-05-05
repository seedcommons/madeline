class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  # Used by LoansController & CalendarController
  # JE Todo: Confirm best place for these shared methods.  "concerns/CalendarEventable"?
  def loan_events(loan)
    events = loan.calendar_events
    loan.project_steps.each{ |step| events.concat(step.calendar_events) }
    events.each{ |event| event.title = render_event(event) }
    events
  end

  private

  def render_event(event)
    render_to_string(partial: "admin/calendar/event", locals: {cal_event: event}).html_safe
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
