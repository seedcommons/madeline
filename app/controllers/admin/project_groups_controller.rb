class Admin::ProjectGroupsController < Admin::AdminController
  include TranslationSaveable

  before_action :find_timeline_entry, only: [:edit, :update, :destroy]

  def new
    @project = Project.find(params[:project_id])
    @parent_group = ProjectGroup.find(params[:parent_id]) if params[:parent_id].present?

    @entry = ProjectGroup.new(project: @project)
    @entry.parent = @parent_group
    authorize @entry

    render_modal_partial
  end

  def edit
    render_modal_partial
  end

  def create
    @entry = ProjectGroup.new(project_group_params)
    authorize @entry

    @project = @entry.project

    parent_id = project_group_params[:parent_id]
    @entry.parent = parent_id.present? ? ProjectGroup.find(parent_id) : @project.root_timeline_entry

    if @entry.save
      render nothing: true
    else
      render_modal_partial(status: 422)
    end
  end

  def update
    if @entry.update(project_group_params)
      render nothing: true
    else
      render_modal_partial(status: 422)
    end
  end

  def destroy
    @entry.destroy!
    head :no_content
  rescue
    flash.now[:error] = I18n.t('project_groups.delete_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  private

  def render_modal_partial(status: 200)
    link_params = params.slice(:project_id, :parent_id)
    render partial: "admin/project_groups/modal_content", status: status
  end

  def project_group_params
    params.require(:project_group).permit([:project_id, :parent_id] + translation_params(:summary))
  end

  def find_timeline_entry
    @entry = ProjectGroup.find(params[:id])
    authorize @entry
  end
end
