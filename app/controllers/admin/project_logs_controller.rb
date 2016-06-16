class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable

  def show
    @log = ProjectLog.find(params[:id])
    authorize_with_parents

    redirect_to admin_loan_path(@loan)
  end

  def new
    @log = ProjectLog.new(project_step_id: params[:step_id])
    authorize_and_render_modal
  end

  def edit
    @log = ProjectLog.find(params[:id])
    authorize_and_render_modal
  end

  def create
    @log = ProjectLog.new(project_log_params)
    authorize_with_parents
    save_and_render_partial
  end

  def update
    @log = ProjectLog.find(params[:id])
    @log.assign_attributes(project_log_params)
    authorize_with_parents
    save_and_render_partial
  end

  def destroy
    @log = ProjectLog.find(params[:id])
    authorize_with_parents
    destroy_and_render_partial
  end

  private

  def authorize_and_render_modal
    authorize_with_parents
    @progress_metrics = ProjectLog.progress_metric_options
    render "modal", layout: false
  end

  def authorize_with_parents
    @step = ProjectStep.find(@log.project_step_id)
    @loan = Loan.find(@step.project_id)

    authorize @log
    authorize @step
    authorize @loan
  end

  def project_log_params
    params.require(:project_log).permit(*(
      [:agent_id, :date, :project_step_id, :progress_metric_value] +
      translation_params(:summary, :details, :additional_notes, :private_notes)))
  end

  # Renders show partial on success, form partial on failure.
  def save_and_render_partial
    if @log.save
      @step.set_completed!(@log.date) if params[:step_completed_on_date] == '1'
      @expand_logs = true
      render partial: 'admin/project_steps/project_step', locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    else
      render partial: 'admin/project_logs/form', locals: {log: @log, step: @step}, status: 422
    end
  end

  def destroy_and_render_partial
    if @log.destroy
      @expand_logs = @step.logs_count > 0
      render partial: 'admin/project_steps/project_step', locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    end
  end
end
