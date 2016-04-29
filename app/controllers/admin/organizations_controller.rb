class Admin::OrganizationsController < Admin::AdminController
  def index
    authorize Organization.new(division: current_division)
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
    authorize @org
    @countries = Country.all
    @form_action_url = admin_organization_path
  end

  def new
    @org = Organization.new(division: current_division)
    authorize @org
    @countries = Country.all
    @form_action_url = admin_organizations_path
  end

  def update
    @org = Organization.find(params[:id])
    authorize @org

    if @org.update(organization_params)
      redirect_to admin_organization_path(@org), notice: I18n.t(:notice_updated)
    else
      @countries = Country.all
      @form_action_url = admin_organization_path
      render :show
    end
  end

  def create
    @org = Organization.new(organization_params)
    @org.division = current_division

    authorize @org

    if @org.save
      redirect_to admin_organization_path(@org), notice: I18n.t(:notice_created)
    else
      @countries = Country.all
      @form_action_url = admin_organizations_path
      render :new
    end
  end

  def destroy
    @org = Organization.find(params[:id])
    authorize @org

    if @org.destroy
      redirect_to admin_organizations_path, notice: I18n.t(:notice_deleted)
    else
      @countries = Country.all
      @form_action_url = admin_organization_path
      render :show
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :street_address, :city, :state, :country_id, :website)
    end
end
