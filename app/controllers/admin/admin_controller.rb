class Admin::AdminController < ApplicationController
  include DivisionSelectable
  helper_method :selected_division_id, :selected_division

  before_action :authenticate_user!
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def admin_controller?
    true
  end

  def user_not_authorized
    if request.xhr?
      render nothing: true, status: 403
    else
      flash[:error] = t('unauthorized_error')
      redirect_to(request.referrer || root_path)
    end
  end
end
