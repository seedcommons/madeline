class Admin::ProjectStepMovesController < Admin::AdminController
  def new
    @step = ProjectStep.find(params[:step_id])
    authorize @step, :update?
    @step_move = ProjectStepMove.new(step: @step)
    @progress_metrics = ProjectLog.progress_metric_options
    @log = ProjectLog.new(project_step_id: params[:step_id])
    @context = params[:context]
    render layout: false
  end

  #
  # # Updates scheduled date of all project steps following this
  # def shift_subsequent
  #   @step = ProjectStep.find(params[:id])
  #   num_days = params[:num_days].to_i
  #   authorize @step
  #   ids = @step.subsequent_step_ids(@step.scheduled_date - num_days.days)
  #   unused, notice = batch_operation(ids){ |step| step.adjust_scheduled_date(num_days) }
  #   display_timeline(@step.project_id, notice)
  # end
end
