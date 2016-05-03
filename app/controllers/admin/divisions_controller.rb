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
    authorize Division
    @divisions_grid = initialize_grid(
      policy_scope(Division),
      order: 'name',
      per_page: 50
    )
    @parent_filter_choices = current_user.accessible_divisions.map{ |d| [d.name, d.id] }
  end

  # show view includes edit
  def show
    @division = Division.find(params[:id])
    authorize @division
    # Todo: Confirm best way to factor these view helper data structures.
    # Started to following the example set by the OrganizationsController here, but seems better
    # to provide helper methods for the view to directly call.
    # @currency_choices = Currency.all
    # @parent_choices = parent_choices(@division)
    @form_action_url = admin_division_path
  end

  def new
    @division = Division.new(parent: current_division)
    authorize @division
    # @currency_choices = Currency.all
    # @parent_choices = parent_choices(@division)
    @form_action_url = admin_divisions_path
  end

  def update
    @division = Division.find(params[:id])
    authorize @division

    if @division.update(division_params)
      redirect_to admin_division_path(@division), notice: I18n.t(:notice_updated)
    else
      # @currency_choices = Currency.all
      # @parent_choices = parent_choices(@division)
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
      # @currency_choices = Currency.all
      # @parent_choices = parent_choices(@division)
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
      # @currency_choices = Currency.all
      # @parent_choices = parent_choices(@division)
      @form_action_url = admin_division_path
      render :show
    end
  end

  private

  def division_params
    params.require(:division).permit(:name, :description, :default_currency_id, :parent_id)
  end

  def set_selected_division_id(id)
    id = nil if id.blank?
    session[:selected_division_id] = id
  end

end
