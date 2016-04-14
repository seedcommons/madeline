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
    if @step.update_with_translations(project_step_params, translations_params(@step.permitted_locales))
      render partial: "/admin/loans/timeline/project_step", locals: {step: @step, mode: :show}
    else
      render partial: "/admin/loans/timeline/project_step", locals: {step: @step, mode: :edit}
    end
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

