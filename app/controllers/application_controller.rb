class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

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
