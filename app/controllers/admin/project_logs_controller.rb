class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable, LogControllable

  def show
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    authorize @log

    redirect_to admin_loan_path(@step.project)
  end

  def new
    @log = ProjectLog.new(project_step_id: params[:step_id])
    @step = @log.project_step
    authorize_and_render_modal
  end

  def edit
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    authorize_and_render_modal
  end

  def create
    @log = ProjectLog.new(project_log_params)
    @step = @log.project_step
    authorize @log
    save_and_render_partial
  end

  def update
    @log = ProjectLog.find(params[:id])
    @log.assign_attributes(project_log_params)
    @step = @log.project_step
    authorize @log
    save_and_render_partial
  end

  def destroy
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    authorize @log
    destroy_and_render_partial
  end
end
