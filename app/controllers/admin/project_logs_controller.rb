class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable

  def show
    @log = ProjectLog.find(params[:id])
    authorize_with_parents

    redirect_to admin_loan_path(@loan)
  end

  def new
    @log = ProjectLog.new(project_step_id: params[:step_id])
    authorize_with_parents
    @progress_metrics = ProjectLog.progress_metric_options
    render "admin/logs/new", layout: false
  end

  def edit
    @log = ProjectLog.find(params[:id])
    authorize_with_parents
    @progress_metrics = ProjectLog.progress_metric_options
    render "admin/logs/edit", layout: false, locals: {log: @log}
  end

  def create
    @log = ProjectLog.new(project_log_attribs)
    authorize_with_parents
    save_and_render_partial
  end

  def update
    @log = ProjectLog.find(params[:id])
    @log.assign_attributes(project_log_attribs)
    authorize_with_parents

    if params[:step_completed_on_date] == '1'
      log_params = params[:project_log]
      completed_date = Date.new log_params["date(1i)"].to_i, log_params["date(2i)"].to_i, log_params["date(3i)"].to_i
      @step.completed_date = completed_date
      @step.save
    end

    save_and_render_partial
  end

  def destroy
    @log = ProjectLog.find(params[:id])
    authorize_with_parents

    if @log.destroy
      redirect_to admin_loan_path(@loan, anchor: 'timeline'), notice: I18n.t(:notice_deleted)
    else
      redirect_to admin_loan_path(@loan, anchor: 'timeline')
    end
  end

  private

  def authorize_with_parents
    @step = ProjectStep.find(@log.project_step_id)
    @loan = Loan.find(@step.project_id)

    authorize @log
    authorize @step
    authorize @loan
  end

  def project_log_attribs
    params.require(:project_log).permit(*(
      [:agent_id, :date, :project_step_id, :progress_metric_value] +
      translation_params(:summary, :details, :additional_notes, :private_notes)))
  end

  # Renders show partial on success, form partial on failure.
  def save_and_render_partial
    if @log.save
      @expand_logs = true
      render partial: 'admin/project_steps/project_step', locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    else
      render partial: 'admin/logs/form', locals: {log: @log, step: @step}, status: 422
    end
  end
end
