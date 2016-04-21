class Admin::DivisionsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def select
    redisplay_url = params[:redisplay_url] || root_path
    division_id = params[:division_id]
    division = Division.find_safe(division_id)
    if division
      authorize division
      session[:selected_division_id] = division_id
    else
      authorize current_division
      session[:selected_division_id] = nil
    end
    redirect_to redisplay_url
  end

end
