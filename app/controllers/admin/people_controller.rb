class Admin::PeopleController < Admin::AdminController
  def index
    authorize Person
    @people_grid = initialize_grid(
      policy_scope(Person),
      include: :country,
      conditions: division_index_filter,
      order: 'name',
      per_page: 50,
      name: 'people',
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
    @person = Person.find(params[:id])
    authorize @person
    # @person.prepare_for_edit
    prep_form_vars
    @form_action_url = admin_person_path
  end

  def new
    @person = Person.new(division: current_division)
    authorize @person
    prep_form_vars
    @form_action_url = admin_people_path
  end

  def update
    @person = Person.find(params[:id])
    authorize @person

    if @person.update(person_params)
      redirect_to admin_person_path(@person), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      @form_action_url = admin_person_path
      render :show
    end
  end

  def create
    @person = Person.new(person_params)
    # Note, assumes division assigned as a form param
    authorize @person

    if @person.save
      redirect_to admin_person_path(@person), notice: I18n.t(:notice_created)
    else
      prep_form_vars
      @form_action_url = admin_people_path
      render :new
    end
  end

  def destroy
    @person = Person.find(params[:id])
    authorize @person

    if @person.destroy
      redirect_to admin_people_path, notice: I18n.t(:notice_deleted)
    else
      prep_form_vars
      @form_action_url = admin_person_path(@person)
      render :show
    end
  end

  private

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :street_address, :city, :state, :postal_code, :country_id,
      :primary_phone, :secondary_phone, :email, :tax_no, :birth_date, :website, :contact_notes,
      :division_id, :primary_organization_id,
      :has_online_access, :password, :password_confirmation, :owning_division_role
    )
  end

  def prep_form_vars
    @countries = Country.all
    @organization_choices = organization_choices
    @division_choices = division_choices
    @roles = [:member, :admin, :foo]
  end

  def organization_choices
    organization_policy_scope(Organization.all)
  end
end
