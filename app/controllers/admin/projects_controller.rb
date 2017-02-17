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
    prep_timeline(@project)
    render partial: "admin/timeline/table", locals: {project: @project}
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
end
