class ApplicationController < ActionController::Base
  include NamedRouteOverrides
  include Pundit

  helper_method :admin_loans_path
  helper_method :admin_people_path

  before_action :set_locale

  helper_method :admin_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def admin_controller?
    false
  end

  def user_not_authorized
    flash[:error] = t('unauthorized_error')
    render("application/error_page", status: 401)
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

  # Returns nil if no language header or no language found in header.
  def locale_from_header
    return ENV["STUB_LOCALE"].to_sym if Rails.env.test? && ENV.key?("STUB_LOCALE")

    if (lang_header = request.env["HTTP_ACCEPT_LANGUAGE"])
      lang_header.scan(/^[a-z]{2}/).first&.to_sym
    end
  end
end
