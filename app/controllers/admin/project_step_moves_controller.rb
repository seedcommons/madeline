class Admin::ProjectStepMovesController < Admin::AdminController
  include TranslationSaveable, LogControllable

  def new
    @step = ProjectStep.find(params[:step_id])
    authorize @step, :update?
    @step_move = ProjectStepMove.new(
      step: @step,
      days_shifted: params[:days_shifted],
      context: params[:context]
    )

    set_log_form_vars
    @log = ProjectLog.new(project_step_id: params[:step_id])
    render layout: false
  end

  def create
    @step = ProjectStep.find(params[:project_log][:project_step_id])
    authorize @step, :update?
    @log = ProjectLog.new(project_log_attribs)
    authorize @log, :create?
    @step_move = ProjectStepMove.new(project_step_move_params.merge(step: @step))

    @log.save
    @step_move.execute!

    @expand_logs = true
    set_log_form_vars
    render partial: 'admin/project_steps/project_step', locals: {
      step: @step,
      context: 'timeline',
      mode: :show
    }
  end

  private

  def project_step_move_params
    params.require(:project_step_move).permit(:move_type, :shift_subsequent, :days_shifted, :context)
  end
end
