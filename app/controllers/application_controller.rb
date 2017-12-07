class ApplicationController < ActionController::Base
  include NamedRouteOverrides

  helper_method :admin_loans_path
  helper_method :admin_people_path

  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  helper_method :admin_controller?

  def admin_controller?
    false
  end

  protected

  def division_choices
    current_user.accessible_divisions
  end

  def loan_policy_scope(scope)
    LoanPolicy::Scope.new(current_user, scope).resolve
  end

  def organization_policy_scope(scope)
    OrganizationPolicy::Scope.new(current_user, scope).resolve
  end

  def person_policy_scope(scope)
    PersonPolicy::Scope.new(current_user, scope).resolve
  end

  def default_serializer_options
    {root: false}
  end

  private

  def set_locale
    return I18n.locale = params[:locale] if params[:locale]
    return I18n.locale = locale_from_header if I18n.available_locales.include?(locale_from_header)
    I18n.locale = I18n.default_locale
  end

  def locale_from_header
    if lang_header = request.env['HTTP_ACCEPT_LANGUAGE']
      lang_header.scan(/^[a-z]{2}/).first.to_sym
    end
  end
end
