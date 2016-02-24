class Admin::LoansController < Admin::AdminController
  def index
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
    @organizations = Organization.all
    @form_action_url = admin_loan_path
  end

  def new
    @loan = Loan.new
    @organizations = Organization.all
    @form_action_url = admin_loans_path
  end

  def update
    @loan = Loan.find(params[:id])

    if @loan.update(loan_params)

      # TODO: Loan should not break when loan_type_value is empty
      # Loan type option set needs a fix, remove below when fixed
      if @loan.loan_type_value == ""
        @loan.loan_type_value = nil
        @loan.save
      end

      # TODO: Loan should not break when status_value is empty
      # Loan status option set needs a fix, remove below when fixed
      if @loan.status_value == ""
        @loan.status_value = nil
        @loan.save
      end

      redirect_to admin_loan_path(@loan), notice: I18n.t(:notice_updated)
    else
      @organizations = Organization.all
      @form_action_url = admin_loan_path
      render :show
    end
  end

  def create
    @loan = Loan.new(loan_params)

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
