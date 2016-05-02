class Admin::AdminController < ApplicationController
  include DivisionSelectable
  helper_method :selected_division_id

  before_action :authenticate_user!
  after_action :verify_authorized
end
