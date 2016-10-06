class Admin::ProjectGroupsController < Admin::AdminController
  include TranslationSaveable

  def new
    @loan = Loan.find(params[:loan_id])
    @entry = ProjectGroup.new(project: @loan)
    authorize @entry

    render_modal_partial
  end

  def create
    @entry = ProjectGroup.new(project_group_params)
    authorize @entry

    @loan = @entry.project
    @entry.parent = @loan.root_timeline_entry

    if @entry.save
      render partial: "admin/loans/timeline/table/timeline_table", loan: @loan
    else
      render_modal_partial(status: 422)
    end
  end

  private

  def render_modal_partial(status: 200)
    link_params = params.slice(:loan_id)
    @submit_url = @entry.new_record? ? admin_project_groups_path(link_params) : edit_admin_project_groups_path(link_params)
    render partial: "admin/project_groups/modal_content", status: status
  end

  def project_group_params
    params.require(:project_group).permit([:project_id, :project_type] + translation_params(:summary))
  end
end
