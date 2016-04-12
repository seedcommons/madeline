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
end
