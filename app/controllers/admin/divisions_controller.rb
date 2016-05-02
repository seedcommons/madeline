class Admin::DivisionsController < Admin::AdminController

  before_action :authenticate_user!
  after_action :verify_authorized

  def select
    redisplay_url = params[:redisplay_url] || root_path
    division_id = params[:division_id]
    set_selected_division_id(division_id)
    division = Division.find_safe(division_id)
    authorize division || current_division
    redirect_to redisplay_url
  end

  def index
    @new_tran = t(".new")
    authorize Division
    @divisions_grid = initialize_grid(
      Division,
      order: 'name',
      per_page: 50
    )
  end

  # show view includes edit
  def show
    @division = Division.find(params[:id])
    authorize @division
    @potential_parents = potential_parents
    @form_action_url = admin_division_path
  end

  def new
    @division = Division.new(parent: current_division)
    authorize @division
    @potential_parents = potential_parents
    @form_action_url = admin_divisions_path
  end

  def update
    @division = Division.find(params[:id])
    authorize @division

    if @division.update(division_params)
      redirect_to admin_division_path(@division), notice: I18n.t(:notice_updated)
    else
      @potential_parents = potential_parents
      @form_action_url = admin_division_path
      render :show
    end
  end

  def create
    @division = Division.new(division_params)
    authorize @division

    if @division.save
      redirect_to admin_division_path(@division), notice: I18n.t(:notice_created)
    else
      @potential_parents = potential_parents
      @form_action_url = admin_divisions_path
      render :new
    end
  end

  def destroy
    @division = Division.find(params[:id])
    authorize @division

    if @division.destroy
      redirect_to admin_divisions_path, notice: I18n.t(:notice_deleted)
    else
      @potential_parents = potential_parents
      @form_action_url = admin_division_path
      render :show
    end
  end

  private

  def division_params
    params.require(:division).permit(:name, :parent_id)
  end

  # List of other divisions which are allowed to be reassigned as parent to this division.
  #fixme: exclude self and children
  def potential_parents
    Division.all
  end

  def set_selected_division_id(id)
    id = nil if id.blank?
    session[:selected_division_id] = id
  end

end
