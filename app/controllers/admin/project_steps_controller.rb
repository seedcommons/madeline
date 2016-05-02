class Admin::ProjectStepsController < Admin::AdminController
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    authorize @step

    if @step.destroy
      display_timeline(@step.project_id, I18n.t(:notice_deleted))
    else
      display_timeline(@step.project_id)
    end
  end

  def new
    @loan = Loan.find(params[:loan_id])
    @step = ProjectStep.new(project: @loan)
    authorize @step
    render_step_partial(:form)
  end

  def show
    @step = ProjectStep.find(params[:id])
    authorize @step

    display_timeline(@step.project_id)
  end

  def create
    # We initialize with project_step_params here to given enough info for authorize to work
    @step = ProjectStep.new(project_step_params)
    authorize @step

    # This will likely be refactored in future to use nested attributes
    # Passing an empty hash for first param because we already initialized params above
    valid = @step.update_with_translations({}, translations_params(@step.permitted_locales))
    render_step_partial(valid ? :show : :form)
  end

  def update
    @step = ProjectStep.find(params[:id])
    authorize @step

    @step.assign_attributes(project_step_params)
    days_shifted = @step.pending_days_shifted # Detect potential schedule shift.
    subsequent_count = @step.subsequent_step_ids.size
    valid = @step.update_with_translations(project_step_params, translations_params(@step.permitted_locales))
    # Ignore schedule shift if not successfully saved, or no subsequent steps to update.
    days_shifted = 0 unless valid && subsequent_count > 0
    render partial: "/admin/project_steps/project_step", locals: {step: @step,
      mode: valid ? :show : :edit, days_shifted: days_shifted, subsequent_count: subsequent_count}
  end

  # Updates scheduled date of all project steps following this
  def shift_subsequent
    @step = ProjectStep.find(params[:id])
    num_days = params[:num_days].to_i
    authorize @step
    ids = @step.subsequent_step_ids(@step.scheduled_date - num_days.days)
    unused, notice = batch_operation(ids){ |step| step.adjust_scheduled_date(num_days) }
    display_timeline(@step.project_id, notice)
  end

  def duplicate
    step = ProjectStep.find(params[:id])
    authorize step
    @steps = step.duplication.perform(params[:duplication])
    render(layout: false)
  end

  def batch_destroy
    step_ids = params[:'step-ids']
    project_id, notice = batch_operation(step_ids) do |step|
      step.destroy
    end
    display_timeline(project_id, notice)
  end

  def adjust_dates
    step_ids = params[:'step-ids']
    time_direction = params[:time_direction]
    num_of_days = params[:num_of_days].to_i

    sign = case time_direction
       when 'forward'
         1
       when 'backward'
         -1
       else
         raise "adjust_dates - unexpected or missing time_direction: #{time_direction}"
     end
    days_adjustment = sign * num_of_days

    project_id, notice = batch_operation(step_ids) do |step|
      step.adjust_scheduled_date(days_adjustment)
    end
    display_timeline(project_id, notice)
  end

  def finalize
    step_ids = params[:'step-ids']
    project_id, notice = batch_operation(step_ids) do |step|
      step.finalize
    end
    display_timeline(project_id, notice)
  end

  private

  # Returns the two values in an array, the project id, and a 'notice' string needed to redisplay
  # the timeline.
  # 'step_ids' may either be an array of integer or comma separated string
  def batch_operation(step_ids, notice_key: :notice_batch_updated)
    success_count = 0
    failure_count = 0
    project_id = nil
    raise_error = true
    step_ids = step_ids.split(',') if step_ids.is_a?(String)
    step_ids.each do |step_id|
      begin
        step = ProjectStep.find(step_id)
        authorize step
        project_id ||= step.project_id

        # If the block returns false, this indicates no change and this record should be left out of
        # both success and failure counts.
        if yield(step)
          success_count += 1
        end
        raise_error = false
      rescue => e
        Rails.logger.error("project step: #{step_id} - batch operation error: #{e}")
        raise e if raise_error
        failure_count += 1
      end
    end

    notice = I18n.t(notice_key, count: success_count)
    if failure_count > 0
      notice = [notice, I18n.t(:notice_batch_failures, failure_count: failure_count)].join(" ")
    end

    [project_id, notice]
  end

  def project_step_params
    params.require(:project_step).permit(:is_finalized, :scheduled_date, :completed_date, :step_type_value,
      :project_type, :project_id)
  end

  #todo: factor out into a concern as we implement other translatable forms
  def translations_params(locales)
    translation_params_list = locales.map { |l| %I(locale_#{l} details_#{l} summary_#{l}) }.flatten
    result = params.require(:project_step).permit(translation_params_list + [:deleted_locales])
    # note, the 'deleted_locales' param is JSON encoded because it was easier to treat as a single field at the form level
    result[:deleted_locales] = JSON.parse(result[:deleted_locales])
    result
  end

  def display_timeline(project_id, notice = nil)
    redirect_to admin_loan_path(project_id, anchor: 'timeline'), notice: notice
  end

  private

  def render_step_partial(mode)
    render partial: "/admin/project_steps/project_step", locals: { step: @step, mode: mode }
  end
end

