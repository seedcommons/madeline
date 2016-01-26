class Admin::ProjectStepsController < Admin::AdminController
  def destroy
    @step = ProjectStep.find(params[:id])
    @project = Loan.find(@step.project_id)
    ProjectStep.delete(params[:id])
    flash[:notice] = "Step deleted"
    redirect_to(admin_loan_path(@project))
  end
end
