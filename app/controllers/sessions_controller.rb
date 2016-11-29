class SessionsController < Devise::SessionsController
  include DivisionSelectable
  after_action :after_login, only: :create

  def after_login
    set_to_default_division
  end

  def set_to_default_division
    return unless default_division
    #
    # Without this check, the headerbar logo will not render
    return if default_division.id == Division.root_id

    session[:selected_division_id] = default_division.id
  end
end
