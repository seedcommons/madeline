class Admin::AdminController < ApplicationController
  include DivisionSelectable
  include Documentable

  layout 'admin/signed_in'

  helper_method :selected_division_id, :selected_division, :current_division

  prepend_before_action :authenticate_user!
  after_action :verify_authorized

  helper_method :current_user

  def admin_controller?
    true
  end
end
