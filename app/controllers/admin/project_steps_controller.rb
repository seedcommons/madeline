class Admin::ProjectStepsController < Admin::AdminController
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    if @step.destroy
      redirect_to admin_loan_path(@step.project_id, anchor: 'timeline'), notice: I18n.t(:notice_deleted)
    else
      redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
    end
  end

  def show
    @step = ProjectStep.find(params[:id])
    redirect_to admin_loan_path(@step.project_id, anchor: 'timeline')
  end

  def update
    @step = ProjectStep.find(params[:id])
    if @step.update_with_translations(project_step_params, translations_params(@step.permitted_locales))
      render :partial => "/admin/loans/timeline/project_step", :locals => {step: @step, mode: :show}
    else
      render :partial => "/admin/loans/timeline/project_step", :locals => {step: @step, mode: :edit}
    end
  end

  private
  def project_step_params
    params.require(:project_step).permit(:is_finalized, :scheduled_date, :completed_date, :step_type_value)
  end

  def translations_params(locales)
    translation_params_list = locales.reduce([]) { |res, l|
      res = res + ["locale_#{l}".to_sym, "details_#{l}".to_sym, "summary_#{l}".to_sym]; res
    }
    params.require(:project_step).permit(translation_params_list + [:deleted_locales])
  end

end

