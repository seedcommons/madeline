class Admin::LoansController < Admin::AdminController
  def index
    @loans_grid = initialize_grid(Loan,
      include: [:division, :organization],
      order: 'loans.signing_date',
      order_direction: 'desc',
      custom_order: { 'loans.signing_date' => 'loans.signing_date IS NULL, loans.signing_date' }
    )
  end

  def show
    @loan = Loan.find(params[:id])
  end
end
