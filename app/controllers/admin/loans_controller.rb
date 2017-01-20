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
      order: 'projects.signing_date',
      order_direction: 'desc',
      custom_order: {
        'loans.division_id' => 'LOWER(divisions.name)',
        'loans.organization_id' => 'LOWER(organizations.name)',
        'loans.signing_date' => 'loans.signing_date IS NULL, loans.signing_date',
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
    prep_timeline
    @form_action_url = admin_loan_path
    @steps = @loan.project_steps
    @calendar_events_url = "/admin/calendar_events?loan_id=#{@loan.id}"
    @active_tab = params[:tab].presence || "details"

    render partial: 'admin/loans/details' if request.xhr?
  end

  def new
    @loan = Loan.new(division: current_division, currency: current_division.default_currency)
    @loan.organization_id = params[:organization_id] if params[:organization_id]
    authorize @loan
    prep_form_vars
  end

  # DEPRECATED - please use #timeline
  def steps
    @loan = Loan.find(params[:id])
    authorize @loan, :show?
    render partial: "admin/loans/timeline/list"
  end

  def timeline
    @loan = Loan.find(params[:id])
    authorize @loan, :show?
    prep_timeline
    render partial: "admin/loans/timeline/table"
  end

  def questionnaires
    @loan = Loan.find(params[:id])
    authorize @loan, :show?

    # Value sets are sets of answers to criteria and post analysis question sets.
    @response_sets = ActiveSupport::OrderedHash.new
    @roots = {}
    @questions_json = {}

    Loan::QUESTION_SET_TYPES.each do |kind|
      # If existing set not found, build a blank one with which to render the form.
      @response_sets[kind] = @loan.send(kind) || LoanResponseSet.new(kind: kind, loan: @loan)

      @roots[kind] = @response_sets[kind].loan_question_set.root_group_preloaded
      @questions_json[kind] = @roots[kind].children_applicable_to(@loan).map do |i|
        LoanQuestionSerializer.new(i, loan: @loan)
      end.to_json
    end

    render partial: "admin/loans/questionnaires/main"
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

  def change_date
    @loan = Loan.find(params[:id])
    authorize @loan, :update?
    attrib = params[:which_date] == "loan_start" ? :signing_date : :end_date
    @loan.update_attributes(attrib => params[:new_date])
    render nothing: true
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

  def print
    @loan = Loan.find(params[:id])
    authorize @loan, :show?
    @print_view = true
    @mode = params[:mode]
    @first_image = @loan.media.find {|item| item.kind == 'image'}
    @roots = { criteria: LoanQuestionSet.find_by(internal_name: "loan_criteria").root_group_preloaded }
    prep_attached_links if @mode != "details-only"
  end

  private

  def loan_params
    params.require(:loan).permit(*(
      [
        :division_id, :organization_id, :loan_type_value, :status_value, :name,
        :amount, :currency_id, :primary_agent_id, :secondary_agent_id,
        :length_months, :rate, :signing_date, :first_payment_date, :first_interest_payment_date,
        :end_date, :projected_return, :representative_id,
        :project_type_value, :public_level_value
      ] + translation_params(:summary, :details)
    ))
  end

  def prep_form_vars
    @division_choices = division_choices
    @organization_choices = organization_policy_scope(Organization.in_division(selected_division)).order(:name)
    @agent_choices = person_policy_scope(Person.in_division(selected_division).where(has_system_access: true)).order(:name)
    @currency_choices = Currency.all.order(:name)
    @representative_choices = representative_choices
  end

  def prep_timeline
    filters = {}
    filters[:type] = params[:type] if params[:type].present?
    filters[:status] = params[:status] if params[:status].present?
    @loan.root_timeline_entry.filters = filters
    @type_options = ProjectStep.step_type_option_set.translated_list
    @status_options = ProjectStep::COMPLETION_STATUSES.map do |status|
      [I18n.t("project_step.completion_status.#{status}"), status]
    end
  end

  def representative_choices
    raw_choices = @loan.organization ? @loan.organization.people : Person.all
    person_policy_scope(raw_choices).order(:name)
  end

  def prep_print_view
  end

  def prep_attached_links
    @attached_links = @loan.criteria_embedded_urls

    unless @attached_links.empty?
      open_link_text = view_context.link_to(I18n.t('loan.open_links', count: @attached_links.length),
        '#', data: {action: 'open-links', links: @attached_links})
      notice_text = "".html_safe
      notice_text << I18n.t('loan.num_of_links', count: @attached_links.length) << " " << open_link_text
      notice_text << " " << I18n.t('loan.popup_blocker') if @attached_links.length > 1
      flash.now[:alert] = notice_text
    end
  end

end
