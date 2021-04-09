class Public::DivisionsController < Public::PublicController
  layout 'public/main'

  rescue_from Pundit::NotAuthorizedError, with: :find_public_parent

  def show
    @division = Division.find_by(short_name: params[:short_name])
    @selected_division = @division
    authorize @division
    # assume this division is public . ..
    divisions_to_show = @division.self_and_descendants.pluck(:id)
    @loans = policy_scope(Loan.where(division: divisions_to_show ).active_or_completed).page(params[:page]).per(5)
  end

  private

  def find_public_parent
    # find nearest public parent
    # redirect to taht page
  end
end
