class Admin::AdminController < ApplicationController
  include DivisionSelectable
  include Documentable

  layout 'admin/signed_in'

  helper_method :selected_division_id, :selected_division, :selected_division_or_root

  prepend_before_action :authenticate_user!
  after_action :verify_authorized

  helper_method :current_user

  def admin_controller?
    true
  end

  def user_not_authorized
    if request.xhr?
      head :forbidden
    else
      flash[:error] = t("unauthorized_error")
      redirect_to(request.referer || root_path)
    end
  end
end
