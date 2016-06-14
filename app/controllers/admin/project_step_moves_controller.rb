class Admin::ProjectStepMovesController < Admin::AdminController
  def new
    @step = ProjectStep.find(params[:step_id])
    authorize @step, :update?
    @step_move = ProjectStepMove.new
    @progress_metrics = ProjectLog.progress_metric_options
    @log = ProjectLog.new(project_step_id: params[:step_id])
    render layout: false
  end
end
