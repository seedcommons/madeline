class Admin::OrganizationsController < Admin::AdminController
  def index
    authorize Organization
    @organizations_grid = initialize_grid(
      policy_scope(Organization),
      include: :country,
      conditions: division_index_filter,
      order: 'name',
      per_page: 50,
      name: 'organizations',
      enable_export_to_csv: true
    )

    @csv_mode = true

    export_grid_if_requested do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  # show view includes edit
  def show
    @org = Organization.find(params[:id])
    authorize @org
    prep_form_vars
    @form_action_url = admin_organization_path
  end

  def new
    @org = Organization.new(division: current_division)
    authorize @org
    prep_form_vars
    @form_action_url = admin_organizations_path
  end

  def update
    @org = Organization.find(params[:id])
    authorize @org

    if @org.update(organization_params)
      redirect_to admin_organization_path(@org), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
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
      prep_form_vars
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
      prep_form_vars
      @form_action_url = admin_organization_path(@org)
      render :show
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :street_address, :city, :state, :country_id, :website)
    end


  #  alias                    :string
  #  contact_notes            :text
  #  division_id              :integer
  #  email                    :string
  #  fax                      :string
  #  industry                 :string
  #  name                     :string
  #  neighborhood             :string
  #  primary_contact_id       :integer
  #  primary_phone            :string
  #  referral_source          :string
  #  secondary_phone          :string
  #  sector                   :string
  #  tax_no                   :string
  #  website                  :string

  #  organization_snapshot_id :integer


  def prep_form_vars
    @countries = Country.all
  end
end
