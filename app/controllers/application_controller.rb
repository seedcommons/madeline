class ApplicationController < ActionController::Base
  include NamedRouteOverrides

  helper_method :admin_loans_path
  helper_method :admin_people_path

  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # overrides 'route_translator' method to reset locale to English
  skip_around_action :set_locale_from_url
  before_action :set_locale

  helper_method :admin_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def admin_controller?
    false
  end

  def user_not_authorized
    path = Rails.application.routes.recognize_path(request.env['PATH_INFO'])
    path_controller = path[:controller]
    path_action = path[:action]

    # Public loan pages have a different flow when not authorized
    if path_controller == "public/loans" && path_action == "show"
      public_loan_not_authorized(path)
    else
      flash[:error] = t('unauthorized_error')
      redirect_to((request.referer || root_path), status: 401)
    end
  end

  def public_loan_not_authorized(path)
    flash[:error] = t('loan.public.not_authorized')
    redirect_to(public_loans_path(path[:site]), status: 401)
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
    return I18n.locale = locale_from_header if I18n.available_locales.include?(locale_from_header)
    return I18n.locale = params[:locale] if params[:locale]
    I18n.locale = I18n.default_locale
  end

  def locale_from_header
    if lang_header = request.env['HTTP_ACCEPT_LANGUAGE']
      lang_header.scan(/^[a-z]{2}/).first.to_sym
    end
  end
end
