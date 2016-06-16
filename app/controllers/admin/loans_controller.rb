class Admin::LoansController < Admin::AdminController
  include TranslationSaveable

  def index
    # Note, current_division is used when creating new entities and is guaranteed to return a value.
    # selected_division is used for index filtering, and may be unassigned.
    authorize Loan
    @loans_grid = initialize_grid(
      policy_scope(Loan),
      include: [:division, :organization, :currency, :primary_agent, :secondary_agent, :representative],
      conditions: division_index_filter,
      order: 'loans.signing_date',
      order_direction: 'desc',
      custom_order: {
        "divisions.name" => "LOWER(divisions.name)",
        "organizations.name" => "LOWER(organizations.name)",
        'loans.signing_date' => 'loans.signing_date IS NULL, loans.signing_date'
      },
      per_page: 50,
      name: 'loans',
      enable_export_to_csv: true
    )

    @csv_mode = true

    export_grid_if_requested do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @loan = Loan.find(params[:id])
    authorize @loan
    prep_form_vars
    @form_action_url = admin_loan_path
    @steps = @loan.project_steps
    @calendar_events_url = "/admin/calendar_events?loan_id=#{@loan.id}"
  end

  def new
    @loan = Loan.new(division: current_division)
    @loan.organization_id = params[:organization_id] if params[:organization_id]
    authorize @loan
    prep_form_vars
  end

  def update
    @loan = Loan.find(params[:id])
    authorize @loan
    @loan.assign_attributes(loan_params)

    if @loan.save
      redirect_to admin_loan_path(@loan), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      render :show
    end
  end

  def create
    @loan = Loan.new(loan_params)
    authorize @loan

    if @loan.save
      redirect_to admin_loan_path(@loan), notice: I18n.t(:notice_created)
    else
      prep_form_vars
      render :new
    end
  end

  def destroy
    @loan = Loan.find(params[:id])
    authorize @loan

    if @loan.destroy
      redirect_to admin_loans_path, notice: I18n.t(:notice_deleted)
    else
      prep_form_vars
      render :show
    end
  end

  private

  def loan_params
    params.require(:loan).permit(*(
      [
        :division_id, :organization_id, :loan_type_value, :status_value, :name,
        :amount, :currency_id, :primary_agent_id, :secondary_agent_id,
        :length_months, :rate, :signing_date, :first_payment_date, :first_interest_payment_date,
        :target_end_date, :projected_return, :representative_id,
        :project_type_value, :public_level_value
      ] + translation_params(:summary, :details)
    ))
  end

  def prep_form_vars
    @division_choices = division_choices
    @organization_choices = organization_policy_scope(Organization.all).order(:name)
    @agent_choices = person_policy_scope(Person.where(has_system_access: true)).order(:name)
    @currency_choices = Currency.all.order(:name)
    @representative_choices = representative_choices
  end

  def representative_choices
    raw_choices = @loan.organization ? @loan.organization.people : Person.all
    person_policy_scope(raw_choices).order(:name)
  end

end
