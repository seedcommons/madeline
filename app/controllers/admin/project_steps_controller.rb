class Admin::ProjectStepsController < Admin::AdminController
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    authorize @step

    if @step.destroy
      redirect_to admin_loan_path(@step.project_id, anchor: 'timeline'), notice: I18n.t(:notice_deleted)
    else
      redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
    end
  end

  def show
    @step = ProjectStep.find(params[:id])
    authorize @step

    redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
  end

  def update
    @step = ProjectStep.find(params[:id])
    authorize @step

    valid = @step.update_with_translations(project_step_params, translations_params(@step.permitted_locales))
    render partial: "/admin/project_steps/project_step", locals: {step: @step, mode: valid ? :show : :edit}
  end


  def duplicate_step
    puts "duplicate_step - params: #{params}"
    step = ProjectStep.find(params[:id])
    authorize step

    if params[:repeat_duration] == 'custom_repeat'
      frequency = params[:time_unit_frequency].to_i
      time_unit = params[:time_unit].to_sym  # days, weeks, months

      # expects back a Chronic gem compatible string.  i.e. '26th day' or '4th Tuesday'
      month_repeat_on = params[:month_repeat_on]  if time_unit == :months

      end_occurrence_type = params[:end_occurrence_type].to_sym
      if end_occurrence_type == :count
        num_of_occurrences = params[:num_of_occurrences].to_i
        end_date = nil
      else
        end_date = params[:end_date].to_date  # todo: confirm what kind of error handling we want here
        num_of_occurrences = nil
      end

      result = step.duplicate_series(frequency, time_unit, month_repeat_on, num_of_occurrences, end_date)

    else

      new_step = step.create_duplicate(should_persist: false)
      result = [new_step]

    end

    render json: result

  end

  private
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

end

