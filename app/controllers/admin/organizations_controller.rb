class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(
      Organization,
      include: :country,
      order: 'name',
      per_page: 50
    )
  end
end
