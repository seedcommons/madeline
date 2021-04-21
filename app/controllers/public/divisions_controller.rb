class Public::DivisionsController < Public::PublicController
  layout 'public/main'

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  ALLOWED_STATUSES = %w(active completed)

  def show
    @params = { status: params[:status], pg: params[:pg], division: params[:division] }
    @division = Division.find_by(short_name: params[:short_name])
    @selected_division = @division # used for custom colors
    authorize @division
    # assume this division is public . ..
    # loan scope handles filtering loans based on whether their division is public, their status, and their public level value
    divisions_to_include = @division.self_and_descendants&.map(&:id)
    loans_requested = Loan.where(division: divisions_to_include)
    loans_requested = loans_requested.status(params[:status]) if ALLOWED_STATUSES.include?(params[:status])
    @loans = LoanPolicy::Scope.new(:public, loans_requested).resolve.page(params[:page]).per(5)
  end

  private

  def user_not_authorized
    flash[:error] = t('public.divisions.not_authorized')
  end
end
