class Admin::ProjectLogsController < Admin::AdminController
  include TranslationSaveable, LogControllable

  def index
    authorize ProjectLog
    @org = Organization.find(params[:org]) if params[:org]
    @logs = ProjectLog.in_division(selected_division).filter_by(params).
        order('date IS NULL, date DESC, created_at DESC').
        page(params[:page]).per(params[:per_page])
    render layout: false if request.xhr?
  end

  def show
    @log = ProjectLog.find(params[:id])
    @step = @log.project_step
    authorize @log

    redirect_to admin_loan_path(@step.project)
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
    save_and_render_partial

    if params[:notify] && @log.division.notify_on_new_logs?
      @log.division.users.each do |user|
        NotificationMailer.new_log(@log, user).deliver_later
      end
    end
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
