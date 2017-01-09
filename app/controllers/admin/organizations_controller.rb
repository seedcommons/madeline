class Admin::OrganizationsController < Admin::AdminController
  def index
    authorize Organization
    @organizations_grid = initialize_grid(
      policy_scope(Organization),
      include: [:country, :division, :primary_contact, :people],
      conditions: division_index_filter,
      order: 'name',
      custom_order: {
        "organizations.name" => "LOWER(organizations.name)",
        "organizations.city" => "LOWER(organizations.city)"
      },
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

    @notes = @org.notes.order(created_at: :desc)
    @new_note = Note.new(notable: @org)
    authorize @new_note, :new?
  end

  def new
    @org = Organization.new(division: current_division)
    authorize @org
    prep_form_vars
  end

  def update
    @org = Organization.find(params[:id])
    authorize @org

    org_params = organization_params
    # Not sure why params.permit wasn't honoring this field for the native simple_form array
    org_params[:person_ids] = params[:organization][:person_ids]
    if @org.update(org_params)
      redirect_to admin_organization_path(@org), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      render :show
    end
  end

  def create
    @org = Organization.new(organization_params)
    @org.division ||= current_division
    authorize @org

    if @org.save
      redirect_to admin_organization_path(@org), notice: I18n.t(:notice_created)
    else
      prep_form_vars
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
      render :show
    end
  end

  private

  def organization_params
    params.require(:organization).permit(
      :name, :street_address, :city, :state, :country_id, :neighborhood, :website,
      :alias, :email, :fax, :primary_phone, :secondary_phone, :tax_no,
      :industry, :sector, :referral_source, :contact_notes,
      :division_id, :primary_contact_id
    )
  end

  def prep_form_vars
    @countries = Country.order(:name)
    @division_choices = division_choices
    @contact_choices = @org.people.order(:name)
    @people_choices = person_policy_scope(Person.all).order(:name)

    @loans_grid = initialize_grid(
      @org.active_loans,
      order: 'loans.signing_date',
      order_direction: 'desc',
      name: 'loans',
      per_page: 10
    )
  end
end
