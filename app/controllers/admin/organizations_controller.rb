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

  def update
    @coop = Organization.find(params[:id])
    @coop.update!(organization_params)
    # redirect_to admin_organization_url(@coop)
    render plain: admin_organization_url(@coop)
  end
end

private

  def organization_params
    params.require(:organization).permit(:name, :street_address, :city, :state, :country_id, :website)
  end
