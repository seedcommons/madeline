class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(
      Organization,
      include: :country,
      order: 'name'
    )
  end

  def show
    @org = Organization.find(params[:id])
    @countries = Country.all
    @form_url = admin_organization_path
    @form_method = :put
  end

  def new
    @org = Organization.new
    @countries = Country.all
    @form_url = new_admin_organization_path
    @form_method = :post
  end

  def update
    @org = Organization.find(params[:id])
    if @org.update(organization_params)
      redirect_to admin_organization_path(@org), notice: "Record updated."
    else
      show
      render :show
    end
  end
end

private

  def organization_params
    params.require(:organization).permit(:name, :street_address, :city, :state, :country_id, :website)
  end
