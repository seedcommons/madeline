class Admin::BasicProjectsController < Admin::AdminController
  include TranslationSaveable

  def index
    authorize BasicProject

    @basic_projects_grid = initialize_grid(
      policy_scope(BasicProject),
      include: [:primary_agent, :secondary_agent],
      order_direction: 'desc',
      per_page: 50,
      name: 'basic_projects',
      enable_export_to_csv: true
    )

    @csv_mode = true

    export_grid_if_requested do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @project = BasicProject.find(params[:id])
    authorize @project
    prep_form_vars
  end

  def update
    @project = BasicProject.find(params[:id])
    authorize @project
    @project.assign_attributes(basic_project_params)

    if @project.save
      redirect_to admin_basic_project_path(@project), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      render :show
    end
  end

  def destroy
    @project = BasicProject.find(params[:id])
    authorize @project

    if @project.destroy
      redirect_to admin_basic_projects_path, notice: I18n.t(:notice_deleted)
    else
      prep_form_vars
      render :show
    end
  end

  private

  def prep_form_vars
    @agent_choices = policy_scope(Person).in_division(selected_division).where(has_system_access: true).order(:name)
  end

  def basic_project_params
    params.require(:basic_project).permit(:length_months, :name, :primary_agent_id,
      :secondary_agent_id, :signing_date, :status_value)
  end
end
