class Admin::DivisionsController < Admin::AdminController
  before_action :authenticate_user!
  after_action :verify_authorized

  def select
    redisplay_url = params[:redisplay_url] || root_path
    division_id = params[:division_id]
    set_selected_division_id(division_id)
    division = Division.find_safe(division_id)
    authorize division || current_division
    redirect_to redisplay_url
  end

  private

  def set_selected_division_id(id)
    id = nil if id.blank?
    session[:selected_division_id] = id
  end

end
