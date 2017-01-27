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
end
