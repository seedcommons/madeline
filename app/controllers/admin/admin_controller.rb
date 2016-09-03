class Admin::AdminController < ApplicationController
  include DivisionSelectable
  helper_method :selected_division_id, :selected_division

  before_action :authenticate_user!
  after_action :verify_authorized

  def admin_controller?
    true
  end
end
