class Admin::ProjectStepsController < Admin::AdminController
  helper TimeLanguageHelper

  def destroy
    @step = ProjectStep.find(params[:id])
    if @step.destroy
      redirect_to admin_loan_path(@step.project_id), notice: I18n.t(:notice_deleted)
    else
      redirect_to admin_loan_path(@step.project_id)
    end
  end

  def show
    @step = ProjectStep.find(params[:id])
    redirect_to admin_loan_path(@step.project_id)
  end
end
