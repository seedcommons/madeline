class Public::DivisionsController < Public::PublicController
  layout 'public/main'

  def show
    @division = Division.find_by(short_name: params[:short_name])
    @selected_division = @division
    authorize @division
    @loans = policy_scope(@division.loans).page(params[:page]).per(2)
  end
end
