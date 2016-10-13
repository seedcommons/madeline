class Admin::ProjectGroupsController < Admin::AdminController
  include TranslationSaveable

  before_action :find_timeline_entry, only: [:edit, :update, :destroy]

  def new
    @loan = Loan.find(params[:loan_id])
    @parent_group = ProjectGroup.find(params[:parent_id]) if params[:parent_id]

    @entry = ProjectGroup.new(project: @loan)
    @entry.parent = @parent_group
    authorize @entry

    render_modal_partial
  end

  def create
    @entry = ProjectGroup.new(project_group_params)
    authorize @entry

    @loan = @entry.project

    parent_id = project_group_params[:parent_id]
    if parent_id && parent_id.present?
      @entry.parent = ProjectGroup.find(parent_id)
    else
      @entry.parent = @loan.root_timeline_entry
    end

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

  def edit
    render_modal_partial
  end

  def destroy
    if @entry.destroy
      render nothing: true
    else
      render_modal_partial(status: 422)
    end
  end

  private

  def render_modal_partial(status: 200)
    link_params = params.slice(:loan_id, :parent_id)
    render partial: "admin/project_groups/modal_content", status: status
  end

  def project_group_params
    params.require(:project_group).permit([:project_id, :project_type, :parent_id] + translation_params(:summary))
  end

  def find_timeline_entry
    @entry = ProjectGroup.find(params[:id])
    authorize @entry
  end

end
