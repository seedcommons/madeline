class Admin::LoansController < Admin::AdminController
  def index
    # Note, current_division is used when creating new entities and is guaranteed to return a value.
    # selected_division is used for index filtering, and may be unassigned.
    authorize Loan.new(division: current_division)
    @loans_grid = initialize_grid(
      policy_scope(Loan),
      include: [:division, :organization],
      conditions: division_index_filter,
      order: 'loans.signing_date',
      order_direction: 'desc',
      custom_order: { 'loans.signing_date' => 'loans.signing_date IS NULL, loans.signing_date' },
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
    @organizations = Organization.all
    @form_action_url = admin_loan_path
    gon.I18n = @loan.translate(:details, :summary)
    @steps = @loan.project_steps
    @calendar_events_url = "/admin/calendar_events?loan_id=#{@loan.id}"
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

  private

    def loan_params
      params.require(:loan).permit(:amount, :loan_type_value, :organization_id, :status_value)
    end
end
