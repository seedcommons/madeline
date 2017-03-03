class Admin::BasicProjectsController < Admin::ProjectsController
  include TranslationSaveable

  def index
    authorize BasicProject

    @basic_projects_grid = initialize_grid(
      policy_scope(BasicProject),
      include: [:primary_agent, :secondary_agent],
      conditions: division_index_filter,
      order_direction: "desc",
      per_page: 50,
      name: "basic_projects",
      enable_export_to_csv: true
    )

    @csv_mode = true

    export_grid_if_requested('basic_projects': 'basic_projects_grid_definition') do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @basic_project = BasicProject.find(params[:id])
    authorize @basic_project

    case @tab = params[:tab] || "details"
    when "details"
      prep_form_vars
    when "timeline"
      prep_timeline(@basic_project)
    when "timeline_list"
      @steps = @basic_project.project_steps
    when 'logs'
      prep_logs(@basic_project)
    when "calendar"
      @calendar_events_url = "/admin/calendar_events?project_id=#{@basic_project.id}"
    end

    @tabs = %w(details timeline timeline_list logs calendar)
  end

  def new
    @basic_project = BasicProject.new(division: current_division)
    authorize @basic_project
    prep_form_vars
  end

  def update
    @basic_project = BasicProject.find(params[:id])
    authorize @basic_project
    @basic_project.assign_attributes(basic_project_params)

    if @basic_project.save
      redirect_to admin_basic_project_path(@basic_project), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      render :show
    end
  end

  def create
    @basic_project = BasicProject.new(basic_project_params)
    authorize @basic_project

    if @basic_project.save
      redirect_to admin_basic_project_path(@basic_project), notice: I18n.t(:notice_created)
    else
      prep_form_vars
      render :new
    end
  end

  def destroy
    @basic_project = BasicProject.find(params[:id])
    authorize @basic_project

    if @basic_project.destroy
      redirect_to admin_basic_projects_path, notice: I18n.t(:notice_deleted)
    else
      prep_form_vars
      render :show
    end
  end

  private

  def prep_form_vars
    @division_choices = division_choices
    @agent_choices = policy_scope(Person).in_division(selected_division).where(has_system_access: true).order(:name)
  end

  def basic_project_params
    params.require(:basic_project).permit(:division_id, :length_months, :name, :primary_agent_id,
      :secondary_agent_id, :signing_date, :status_value)
  end
end
