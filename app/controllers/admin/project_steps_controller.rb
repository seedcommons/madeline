class Admin::ProjectStepsController < Admin::AdminController
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    authorize @step

    if @step.destroy
      # redirect_to admin_loan_path(@step.project_id, anchor: 'timeline'), notice: I18n.t(:notice_deleted)
      display_timeline(@step, I18n.t(:notice_deleted))
    else
      # redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
      display_timeline(@step)
    end
  end

  def show
    @step = ProjectStep.find(params[:id])
    authorize @step

    # redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
    display_timeline(@step)
  end

  def update
    @step = ProjectStep.find(params[:id])
    authorize @step

    valid = @step.update_with_translations(project_step_params, translations_params(@step.permitted_locales))
    render partial: "/admin/project_steps/project_step", locals: {step: @step, mode: valid ? :show : :edit}
  end

  def batch_destroy
    puts "batch_destroy: params: #{params}"
    step_ids = params[:'step-ids']
    project_id, success_count, failure_count = batch_operation(step_ids) do |step|
      step.destroy
    end
    display_timeline(project_id, I18n.t(:notice_batch_deleted, count: success_count))
  end


  def adjust_dates
    puts "adjust_dates: params: #{params}"
    step_ids = params[:'step-ids']
    time_direction = params[:time_direction]
    num_of_days = params[:num_of_days].to_i

    sign = case time_direction
             when 'forward'
               1
             when 'backward'
               -1
             else
               raises "adjust_dates - unexpected time_direction: #{time_direction}"
           end
    days_adjustment = sign * num_of_days

    project_id, success_count, failure_count = batch_operation(step_ids) do |step|
      step.adjust_scheduled_date(days_adjustment)
    end
    display_timeline(project_id, I18n.t(:notice_batch_updated, count: success_count))
  end

  def finalize
    puts "finalize: params: #{params}"
    step_ids = params[:'step-ids']
    project_id, success_count, failure_count = batch_operation(step_ids) do |step|
      step.finalize
    end
    display_timeline(project_id, I18n.t(:notice_batch_updated, count: success_count))
  end

  private

  def batch_operation step_ids
    success_count = 0
    failure_count = 0
    project_id = nil
    step_ids.split(',').each do |step_id|
      step = ProjectStep.find(step_id)
      authorize step
      project_id ||= step.project_id
      #todo: confirm if we should wrap each operation in a try/catch or let first failure be fatal
      if yield(step)
        success_count += 1
      else
        failure_count += 1
        #todo: confirm if we need any special handling or displayed notice if the destroy fails
      end
    end
    [project_id, success_count, failure_count]
  end


  def project_step_params
    params.require(:project_step).permit(:is_finalized, :scheduled_date, :completed_date, :step_type_value)
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



end

