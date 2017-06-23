class Admin::LoansController < Admin::ProjectsController
  include TransactionListable, TranslationSaveable, QuestionnaireRenderable

  TABS = %w(details questions timeline timeline_list logs transactions calendar)

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
        'projects.division_id' => 'LOWER(divisions.name)',
        'projects.organization_id' => 'LOWER(organizations.name)',
        'projects.signing_date' => 'projects.signing_date IS NULL, projects.signing_date',
      },
      per_page: 50,
      name: 'loans',
      enable_export_to_csv: true
    )

    @csv_mode = true
    @enable_export_to_csv = true

    export_grid_if_requested('loans': 'loans_grid_definition') do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @loan = Loan.find(params[:id])
    authorize @loan
    @active_tab = params[:tab].presence || 'details'

    case @tab = params[:tab] || 'details'
    when 'details'
      prep_form_vars
    when 'questions'
      prep_questionnaire
    when 'timeline'
      prep_timeline(@loan)
    when 'timeline_list'
      @steps = @loan.project_steps
    when 'logs'
      prep_logs(@loan)
    when 'transactions'
      prep_transactions
    when 'calendar'
      @locale = I18n.locale
      @calendar_events_url = "/admin/calendar_events?project_id=#{@loan.id}"
    end

    render partial: 'admin/loans/details' if request.xhr?
  end

  def new
    @loan = Loan.new(division: current_division, currency: current_division.default_currency)
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

  def print
    @loan = Loan.find(params[:id])
    authorize @loan, :show?
    @print_view = true
    @mode = params[:mode]
    @first_image = @loan.media.find {|item| item.kind_value == 'image'}
    @roots = LoanQuestionSet.find_by(internal_name: "loan_criteria").root_group_preloaded
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
    @agent_choices = policy_scope(Person).in_division(selected_division).with_system_access.order(:name)
    @currency_choices = Currency.all.order(:name)
    @representative_choices = representative_choices
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

  def prep_transactions
    @transaction = ::Accounting::Transaction.new(project: @loan)
    @loan_transaction_types = ::Accounting::Transaction::LOAN_TRANSACTION_TYPES
    @add_transaction_available = Division.root.qb_accounts_connected?
    @accounts = Accounting::Account.where(qb_account_classification: 'Asset') - Division.root.accounts

    unless @add_transaction_available
      # We need to use the view helper version of `t` so that we can use the _html functionality.
      flash.now[:alert] = self.class.helpers.t('quickbooks.not_connected_html',
        link: admin_settings_url)
    end

    initialize_transactions_grid(@loan.id)
  end
end
