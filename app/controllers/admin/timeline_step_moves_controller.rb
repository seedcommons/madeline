class Admin::TimelineStepMovesController < Admin::AdminController
  include TranslationSaveable, LogControllable

  def new
    @step = ProjectStep.find(params[:step_id])
    authorize @step, :update?
    @step_move = Timeline::StepMove.new(
      step: @step,
      days_shifted: params[:days_shifted],
      context: params[:context],
      new_end_date: params[:new_end_date]
    )

    set_log_form_vars
    @log = ProjectLog.new(project_step_id: params[:step_id], date: Date.today, agent: current_user.profile)
    render layout: false
  end

  def create
    @step = ProjectStep.find(params[:project_log][:project_step_id])
    authorize @step, :update?
    @log = ProjectLog.new(project_log_params)
    authorize @log, :create?
    @step_move = Timeline::StepMove.new(project_step_move_params.merge(step: @step, log: @log))
    new_end_date = params[:timeline_step_move][:new_end_date]

    if @log.save
      @step.update_column(:actual_end_date, new_end_date)
      @step_move.execute!
      render nothing: true
    else
      set_log_form_vars
      render :new, layout: false, status: :unprocessable_entity
    end
  end

  # A change of date for a step that does not require a corresponding log
  def simple_move
    @step = ProjectStep.find(params[:id])
    authorize @step, :update?
    @step.update_attributes(scheduled_start_date: params[:scheduled_start_date])
    render nothing: true
  end

  private

  def project_step_move_params
    params.require(:timeline_step_move).permit(:move_type, :days_shifted, :context, :new_end_date)
  end
end
