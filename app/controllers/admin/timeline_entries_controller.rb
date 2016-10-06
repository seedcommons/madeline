class Admin::TimelineEntriesController < Admin::AdminController
  include TranslationSaveable

  before_action :find_timeline_entry, :authorize_timeline_entry

  def new
    render_modal_partial
  end

  def create
    render_modal_partial
  end

  private

  def find_timeline_entry
    @loan = Loan.find(params[:loan_id])

    @entry = ProjectGroup.find_or_initialize_by(id: params[:id], project: @loan)
  end

  def authorize_timeline_entry
    authorize @entry
  end

  def render_modal_partial(status: 200)
    # link_params = @entry.attributes
    # @submit_url = @entry.new_record? ? admin_media_index_path(link_params) : admin_media_path(link_params)
    @submit_url = ''
    render partial: "admin/timeline_entries/modal_content", status: status
  end
  #
  # def project_step_move_params
  #   params.require(:timeline_step_move).permit(:move_type, :shift_subsequent, :days_shifted, :context)
  # end
end
