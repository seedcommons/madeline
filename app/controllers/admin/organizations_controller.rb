class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(
      Organization,
      include: :country,
      order: 'name'
    )
  end
end
