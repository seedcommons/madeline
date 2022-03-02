class Admin::BasicProjectsController < Admin::ProjectsController

  TABS = %w(details timeline logs calendar).freeze

  def index
    authorize BasicProject

    @basic_projects_grid = initialize_grid(
      policy_scope(BasicProject).where(status_value: :active),
      include: [:primary_agent, :secondary_agent],
      conditions: division_index_filter,#division_index_filter.merge({status_value: :active}),
      order_direction: "desc",
      per_page: 50,
      name: "basic_projects",
      enable_export_to_csv: true
    )

    @csv_mode = true
    @enable_export_to_csv = true

    export_grid_if_requested('basic_projects': 'basic_projects_grid_definition') do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @basic_project = BasicProject.find(params[:id])
    authorize @basic_project
    @tab = params[:tab]

    case @tab
    when "timeline"
      prep_timeline(@basic_project)
    when "logs"
      prep_logs(@basic_project)
    when "calendar"
      @locale = I18n.locale
      @calendar_events_url = "/admin/calendar_events?project_id=#{@basic_project.id}"
    else
      # Ensure @tab defaults to details if it's set to something unrecognized.
      @tab = "details"
      prep_form_vars
    end
  end

  def new
    @basic_project = BasicProject.new(division: selected_division_or_root)
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

    # All basic projects should be hidden
    @basic_project.public_level_value = 'hidden'

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

  def duplicate
    @basic_project = BasicProject.find(params[:id])
    authorize @basic_project

    new_project = ProjectDuplicator.new(@basic_project).duplicate

    redirect_to(admin_basic_project_path(new_project), notice: I18n.t("basic_project.duplicated_message"))
  end

  private

  def prep_form_vars
    @tab ||= "details"
    @agent_choices = Person.in_ancestor_or_descendant_division(@basic_project.division).by_name
  end

  def basic_project_params
    params.require(:basic_project).permit([:division_id, :length_months, :name, :primary_agent_id,
      :secondary_agent_id, :signing_date, :status_value] + translation_params(:summary, :details))
  end
end
