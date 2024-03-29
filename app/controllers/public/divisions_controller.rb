class Public::DivisionsController < Public::PublicController
  layout "public/main"

  def show
    @params = {status: params[:status], pg: params[:pg]}
    @division = Division.find_by(short_name: params[:short_name])
    @selected_division = @division
    unless @division && @division.public
      render("application/error_page", status: :unauthorized)
    else
      authorize @division
      @status_filter = [:active]
      if @params[:status] == "all"
        @status_filter = [:active, :completed]
      elsif @params[:status]
        @status_filter = [@params[:status]]
      end
      # loan scope handles filtering loans based on whether their division is public,
      # only completed or active loans, and their public level value
      divisions_to_include = @division.self_and_descendants&.map(&:id)
      @loans = policy_scope(
        Loan.where(division: divisions_to_include, status_value: @status_filter)
      ).page(params[:page]).per(5)
    end
  end

  private

  def user_not_authorized
    flash[:error] = t("public.divisions.not_authorized")
  end
end
