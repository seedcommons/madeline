class Admin::LoansController < Admin::AdminController
  def index
    @loans_grid = initialize_grid(
      Loan,
      include: [:division, :organization],
      order: 'division'
    )
  end
end
