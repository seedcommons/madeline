module ProjectConcern
  extend ActiveSupport::Concern

  private

  def change_date(project)
    project = Project.find(params[:id])
    authorize project, :update?
    attrib = params[:which_date] == "project_start" ? :signing_date : :end_date
    project.update_attributes(attrib => params[:new_date])
    render nothing: true
  end

  def prep_timeline(project)
    filters = {}
    filters[:type] = params[:type] if params[:type].present?
    filters[:status] = params[:status] if params[:status].present?
    project.root_timeline_entry.filters = filters
    @type_options = ProjectStep.step_type_option_set.translated_list
    @status_options = ProjectStep::COMPLETION_STATUSES.map do |status|
      [I18n.t("project_step.completion_status.#{status}"), status]
    end
  end
end
