class Admin::LoansController < Admin::AdminController
  def index
    @loans_grid = initialize_grid(Loan, include: [:division, :organization])
  end

  def show
    @loan = Loan.find(params[:id])
  end
end
