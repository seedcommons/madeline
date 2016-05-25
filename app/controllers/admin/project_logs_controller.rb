class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable

  def show
    @log = ProjectLog.find(params[:id])
    authorize_with_parents

    if params[:step_completed_on_date]
      @step.completed_date = params[:project_log][:date]
      redirect_to admin_project_step_url, action: "update", id: @step.id
    end

    redirect_to admin_loan_path(@loan)
  end

  def new
    @log = ProjectLog.new(project_step_id: params[:step_id])
    authorize_with_parents
    render "admin/logs/new", layout: false
  end

  def edit
    @log = ProjectLog.find(params[:id])
    authorize_with_parents

    @progress_metrics = ['behind', 'on_time']

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
    params.require(:project_log).permit(*([:agent_id, :date, :project_step_id, :progress_metric_value] +
      translation_params(:summary, :details, :additional_notes, :private_notes)))
  end

  # Renders show partial on success, form partial on failure.
  def save_and_render_partial
    if @log.save
      render partial: "admin/logs/step_logs", locals: {step: @step}
    else
      render partial: "admin/logs/form", locals: {log: @log, step: @step}, status: 422
    end
  end
end
