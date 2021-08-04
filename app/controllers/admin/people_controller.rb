module Admin
  class PeopleController < Admin::AdminController
    def index
      authorize Person
      @people_grid = initialize_grid(
        policy_scope(Person),
        include: %i[country division primary_organization],
        conditions: division_index_filter,
        order: "name",
        per_page: 50,
        custom_order: {
          "people.name" => ->(col) { Arel.sql("LOWER(#{col})") },
          "people.city" => ->(col) { Arel.sql("LOWER(#{col})") },
          "people.primary_organization_id" => ->(col) { Arel.sql("LOWER(#{col})") }
        },
        name: "people",
        enable_export_to_csv: true
      )

      @csv_mode = true
      @enable_export_to_csv = true

      export_grid_if_requested("people": "people_grid_definition") do
        # This block only executes if CSV is not being returned
        @csv_mode = false
      end
    end

    # show view includes edit
    def show
      @person = Person.find(params[:id])
      authorize @person
      prep_form_vars

      @new_note = Note.new(notable: @person)
      @new_note = nil unless Pundit.policy(current_user, @new_note).new?
    end

    def new
      @person = Person.new(division: current_division)
      authorize @person
      prep_form_vars
    end

    def update
      @person = Person.find(params[:id])
      authorize @person

      if @person.update(person_params)
        redirect_to admin_person_path(@person), notice: I18n.t(:notice_updated)
      else
        prep_form_vars
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
        render :show
      end
    end

    private

    def person_params
      params.require(:person).permit(
        :first_name, :last_name, :street_address, :city, :state, :postal_code, :country_id,
        :primary_phone, :secondary_phone, :email, :tax_no, :birth_date, :website, :contact_notes,
        :division_id, :primary_organization_id,
        :has_system_access, :password, :password_confirmation, :access_role
      )
    end

    def prep_form_vars
      @countries = Country.order(:name)
      @organization_choices = organization_choices
      @roles_choices = role_choices
      @notes = @person.notes.order(created_at: :desc)
    end

    def role_choices
      Person::VALID_DIVISION_ROLES
    end

    def organization_choices
      organization_policy_scope(Organization.in_division(selected_division)).order(:name)
    end
  end
end
