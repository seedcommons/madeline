class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  # Used by LoansController & CalendarController
  # JE Todo: Confirm best place for these shared methods.  "concerns/CalendarEventable"?
  # def loan_events(loan, render: true)
  #   events = loan.calendar_events
  #   loan.project_steps.each{ |step| events.concat(step.calendar_events) }
  #   if render
  #     events.each{ |event| event.html = render_event(event) } #JE Todo: remove once data fetched via source api
  #     events.each{ |event| event.title = render_event(event) }
  #   end
  #   events
  # end

  def loan_policy_scope(scope)
    LoanPolicy::Scope.new(current_user, scope).resolve
  end

  # JE: Not sure why my class level 'root=false' initializers didn't seem to work to disable the
  # root json element when serialiing, but this seems to do the trick.
  def default_serializer_options
    {root: false}
  end

  private

  def render_event(event)
    render_to_string(partial: "admin/calendar/event", locals: {cal_event: event}).html_safe
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
