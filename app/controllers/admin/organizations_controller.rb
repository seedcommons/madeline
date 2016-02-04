class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations_grid = initialize_grid(
      Organization,
      include: :country,
      order: 'name',
      per_page: 50
    )
  end

  # show view includes edit
  def show
    @org = Organization.find(params[:id])
    @countries = Country.all
    @form_action_url = admin_organization_path
  end

  def new
    @org = Organization.new
    @countries = Country.all
    @form_action_url = admin_organizations_path
  end

  def update
    @org = Organization.find(params[:id])
    if @org.update(organization_params)
      redirect_to admin_organization_path(@org), notice: "Record updated."
    else
      @countries = Country.all
      @form_action_url = admin_organization_path
      render :show
    end
  end

  def create
    @org = Organization.new(organization_params)
    @org.division = current_division

    if @org.save
      redirect_to admin_organization_path(@org), notice: 'Record was successfully created.'
    else
      @countries = Country.all
      @form_action_url = admin_organizations_path
      render :new
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :street_address, :city, :state, :country_id, :website)
    end
end
