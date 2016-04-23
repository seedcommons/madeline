class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_division

  def current_division
    # TODO
    Division.root
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
