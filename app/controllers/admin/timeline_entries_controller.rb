class Admin::TimelineEntriesController < Admin::AdminController
  include TranslationSaveable

  def new
    @loan = Loan.find(params[:loan_id])

    @entry = ProjectGroup.find_or_initialize_by(id: params[:id], project: @loan)
    authorize @entry

    render_modal_partial
  end

  def create
    @entry = ProjectGroup.new(project_group_params)
    authorize @entry

    @loan = @entry.project

    if @entry.save
      render partial: "admin/loans/timeline/table/timeline_table", loan: @loan
    else
      render_modal_partial(status: 422)
    end
  end

  private

  def render_modal_partial(status: 200)
    link_params = params.slice(:loan_id)
    @submit_url = @entry.new_record? ? admin_timeline_entries_path(link_params) : edit_admin_timeline_entry_path(link_params)
    render partial: "admin/timeline_entries/modal_content", status: status
  end

  def project_group_params
    params.require(:project_group).permit([:project_id, :project_type] + translation_params(:summary))
  end
end
