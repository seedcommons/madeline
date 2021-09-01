class SessionsController < Devise::SessionsController
  include DivisionSelectable
  after_action :after_login, only: :create

  def after_login
    set_to_default_division
  end

  def set_to_default_division
    return unless current_user.default_division

    # Without this check, the headerbar logo will not render
    return if current_user.default_division.root?

    session[:selected_division_id] = current_user.default_division_id
  end
end
