class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(
      Organization,
      include: :country,
      order: 'name'
    )
  end

  def show
    @coop = Organization.find(params[:id])
    @countries = Country.all
  end

  def new
    @coop = Organization.new
    @countries = Country.all
  end
end
