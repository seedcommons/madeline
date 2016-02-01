class Admin::LoansController < Admin::AdminController
  def index
    @loans_grid = initialize_grid(Loan, include: [:division, :organization])

    # TODO:
      # Only load coops/organizations with loans into loan grid
      # Filter in view should only show coops with loans

    # TODO:
      # "loan.name" and "loan[:name]" currently return different, unrelated content.
      # Should return same content.
      # By default wice grid uses "object.option" and not "object[:option]"
      # Difference may be related to use of FactoryGirl

    # TODO: Loan type is currently nil
  end
end
