class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable, LogControllable

  def index
    authorize ProjectLog
    @org = Organization.find(params[:org]) if params[:org]
    @step = ProjectStep.find(params[:step]) if params[:step]
    @logs = ProjectLog.in_division(selected_division).filter_by(params).by_date.page(params[:page]).
      per(params[:per_page])

    render partial: "admin/project_logs/log_list" if request.xhr?
  end

  def show
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    authorize @log
  end

  def new
    @log = ProjectLog.new(project_step_id: params[:step_id], date: Date.today, agent: current_user.profile)
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
    save_and_render
  end

  def update
    @log = ProjectLog.find(params[:id])
    @log.assign_attributes(project_log_params)
    @step = @log.project_step
    authorize @log

    if params[:context] == 'timeline'
      save_and_render_partial
    else
      save_and_render
    end
  end

  def destroy
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    @logs = @step.project_logs
    @context = params[:context]
    authorize @log

    destroy_and_render_partial
  end

  private

  def save_and_render
    if @log.save
      @step.set_completed!(@log.date) if params[:step_completed_on_date] == '1'
      @expand_logs = true
      render json: {summary: @log.summary, logId: @log.id}, status: 200
      LogNotificationJob.perform_later(@log) if params[:notify] == '1'
    else
      @progress_metrics = ProjectLog.progress_metric_options
      @people = Person.by_name
      render partial: 'modal_content', status: :unprocessable_entity
    end
  end
end
