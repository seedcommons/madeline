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
      conditions: index_filter,
      order: 'name',
      per_page: 50
    )
    @parent_filter_choices = current_user.accessible_divisions.map{ |d| [d.name, d.id] }
  end

  # show view includes edit
  def show
    @division = Division.find(params[:id])
    authorize @division
    prep_form_vars
    @form_action_url = admin_division_path
  end

  def new
    @division = Division.new(parent: current_division)
    authorize @division
    prep_form_vars
    @form_action_url = admin_divisions_path
  end

  def update
    @division = Division.find(params[:id])
    authorize @division

    if @division.update(division_params)
      redirect_to admin_division_path(@division), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      @form_action_url = admin_division_path
      render :show
    end
  end

  def create
    @division = Division.new(division_params)
    if @division.parent
      authorize @division
    else
      # Let record with missing parent bypass the policy check so a validation message will be
      # presented to the user, instead of fatal exception thrown.
      skip_authorization
    end

    if @division.save
      redirect_to admin_division_path(@division), notice: I18n.t(:notice_created)
    else
      prep_form_vars
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
      prep_form_vars
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

  def index_filter
    selected = selected_division
    selected ? {id: selected.self_and_descendant_ids} : nil
  end

  def prep_form_vars
    @currency_choices = Currency.all
    @parent_choices = parent_choices(@division)
  end

  # List of other divisions which the current user has access to and are allowed to be assigned
  # as a parent to this division.
  def parent_choices(division)
    (current_user.accessible_divisions - division.self_and_descendants) | [division.parent]
  end
end
