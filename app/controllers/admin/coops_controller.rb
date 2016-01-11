class Admin::CoopsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(Organization)
  end
end
