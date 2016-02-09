class Admin::AdminController < ApplicationController
  before_action :authenticate_user!

  def current_division
    # TODO
    Division.root
  end
end
