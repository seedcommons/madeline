class Admin::ProjectStepsController < Admin::AdminController
  include TranslationSaveable
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    authorize @step

    if request.xhr?
      @step.destroy
      render nothing: true
    else
      if @step.destroy
        display_timeline(@step.project_id, I18n.t(:notice_deleted))
      else
        display_timeline(@step.project_id)
      end
    end
  end

  def new
    @loan = Loan.find(params[:loan_id])
    @step = ProjectStep.new(project: @loan, scheduled_start_date: params[:date])
    authorize @step
    if params[:context] == "timeline_table"
      render_modal_content
    else
      params[:context] = "timeline" unless params[:context]
      render_step_partial(:form)
    end
  end

  def show
    @step = ProjectStep.find(params[:id])
    authorize @step

    if request.xhr?
      render_step_partial(:show)
    else
      display_timeline(@step.project_id)
    end
  end

  def create
    # We initialize with project_step_params here to given enough info for authorize to work
    @step = ProjectStep.new(project_step_params)
    authorize @step
    @step.parent = @step.project.root_timeline_entry
    valid = @step.save
    render_step_partial(valid ? :show : :form)
  end

  def update
    @step = ProjectStep.find(params[:id])
    authorize @step

    @step.assign_attributes(project_step_params)

     # Detect potential schedule shift.
    days_shifted = @step.pending_days_shifted

    valid = @step.save

    # Ignore schedule shift if not successfully saved
    days_shifted = 0 unless valid

    render partial: "/admin/project_steps/project_step", locals: {
      step: @step,
      mode: valid ? :show : :edit,
      days_shifted: days_shifted,
      context: params[:context]
    }
  end

  def duplicate
    step = ProjectStep.find(params[:id])
    authorize step
    @steps = step.duplication.perform(params[:duplication])
    render(layout: false)
  end

  def batch_destroy
    project_id, notice = Timeline::BatchDestroy.new(current_user,
      params['step-ids'],
      notice_key: :notice_batch_deleted).perform

    # Auth is done in BatchDestroy, but controller doesn't realize
    skip_authorization

    display_timeline(project_id, notice)
  end

  def adjust_dates
    project_id, notice = Timeline::DateAdjustment.new(current_user,
      params['step-ids'],
      time_direction: params[:time_direction],
      num_of_days: params[:num_of_days].to_i).perform

    # Auth is done in DateAdjustment, but controller doesn't realize
    skip_authorization

    display_timeline(project_id, notice)
  end

  def finalize
    project_id, notice = Timeline::BatchFinalize.new(current_user, params['step-ids']).perform

    # Auth is done in BatchFinalize, but controller doesn't realize
    skip_authorization

    display_timeline(project_id, notice)
  end

  private

  def project_step_params
    params.require(:project_step).permit(*([:is_finalized, :scheduled_start_date, :actual_end_date,
      :scheduled_duration_days, :step_type_value, :project_type,
      :project_id] + translation_params(:summary, :details)))
  end

  def display_timeline(project_id, notice = nil)
    redirect_to admin_loan_path(project_id, anchor: 'timeline'), notice: notice
  end

  private

  def render_step_partial(mode)
    render partial: "/admin/project_steps/project_step", locals: {
      step: @step,
      mode: mode,
      context: params[:context]
    }
  end

  def render_modal_content
    render partial: "/admin/project_steps/modal_content", locals: {
      step: @step,
      context: params[:context]
    }
  end
end
