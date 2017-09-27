class Admin::ProjectsController < Admin::AdminController
  include TranslationSaveable

  def change_date
    project = Project.find(params[:id])
    authorize project, :update?
    attrib = params[:which_date] == "project_start" ? :signing_date : :end_date
    project.update_attributes(attrib => params[:new_date])
    render nothing: true
  end

  # DEPRECATED - please use #timeline
  def steps
    @project = Project.find(params[:id])
    authorize @project, :show?
    render partial: "admin/timeline/list", locals: {project: @project}
  end

  def timeline
    @project = Project.find(params[:id])
    authorize @project, :show?
    if request.xhr?
      prep_timeline(@project)
      render partial: "admin/timeline/table", locals: {project: @project}
    else
      redirect_to send("admin_#{@project.model_name.singular}_tab_path", @project, tab: 'timeline')
    end
  end

  def show
    @project = Project.find(params[:id])
    authorize @project, :show?
    case @project.type
    when 'Loan'
      redirect_to admin_loan_tab_path(@project, tab: 'details')
    when 'BasicProject'
      redirect_to admin_basic_project_path(@project, tab: 'details')
    end
  end

  protected

  def prep_timeline(project)
    filters = {}
    filters[:type] = params[:type] if params[:type].present?
    filters[:status] = params[:status] if params[:status].present?
    project.root_timeline_entry.filters = filters
    @type_options = ProjectStep.step_type_option_set.translated_list
    @status_options = %w(finalized incomplete complete).map do |status|
      [I18n.t("project_step.completion_status.#{status}"), status]
    end
  end

  def prep_logs(project)
    @org = Organization.find(params[:org]) if params[:org]
    @step = ProjectStep.find(params[:step]) if params[:step]
    @logs = ProjectLog.in_division(selected_division).filter_by(project: project.id).
        order('date IS NULL, date DESC, created_at DESC').
        page(params[:page]).per(params[:per_page])
  end
end
