class Admin::LoansController < Admin::AdminController
  def index
    authorize Loan.new(division: current_division)
    @loans_grid = initialize_grid(Loan,
      include: [:division, :organization],
      order: 'loans.signing_date',
      order_direction: 'desc',
      custom_order: { 'loans.signing_date' => 'loans.signing_date IS NULL, loans.signing_date' },
      per_page: 50
    )
  end

  def show
    @loan = Loan.find(params[:id])
    authorize @loan
    @organizations = Organization.all
    @form_action_url = admin_loan_path
    gon.I18n = @loan.translate(:details, :summary)
    @steps = @loan.project_steps

    # TODO: Move calendar logic to resuable concern
    @calEvents = []
    prepare_event(@loan.calendar_start_event)
    prepare_event(@loan.calendar_end_event)

    @loan.project_steps.each do |step|
      prepare_event(step.calendar_scheduled_event)
      prepare_event(step.calendar_original_scheduled_event)
    end
  end

  def new
    @loan = Loan.new(division: current_division)
    authorize @loan
    @organizations = Organization.all
    @form_action_url = admin_loans_path
  end

  def update
    @loan = Loan.find(params[:id])
    authorize @loan

    if @loan.update(loan_params)
      redirect_to admin_loan_path(@loan), notice: I18n.t(:notice_updated)
    else
      @organizations = Organization.all
      @form_action_url = admin_loan_path
      render :show
    end
  end

  def create
    @loan = Loan.new(loan_params).merge(division: current_division)
    authorize @loan

    if @loan.save
      redirect_to admin_loan_path(@loan), notice: I18n.t(:notice_created)
    else
      @organizations = Organization.all
      @form_action_url = admin_loans_path
      render :new
    end
  end

  def destroy
    @loan = Loan.find(params[:id])
    authorize @loan

    if @loan.destroy
      redirect_to admin_loans_path, notice: I18n.t(:notice_deleted)
    else
      @organizations = Organization.all
      @form_action_url = admin_loan_path
      render :show
    end
  end

  # TODO: Move to reusable concern
  def prepare_event(cal_event)
    content = render_to_string(partial: "admin/calendar/event", locals: {cal_event: cal_event}).html_safe
    cal_event[:title] = content
    @calEvents.push(cal_event)
  end

  private

    def loan_params
      params.require(:loan).permit(:amount, :loan_type_value, :organization_id, :status_value)
    end
end
