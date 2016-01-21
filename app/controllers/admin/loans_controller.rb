class Admin::LoansController < Admin::AdminController
  def index
    @loans_grid = initialize_grid(
      Loan
      # include: :country,
      # order: 'name'
    )
  end
end
