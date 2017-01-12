class Admin::LoanResponseSetsController < Admin::AdminController
  def create
    @record = LoanResponseSet.new(record_params)
    authorize @record
    @record.save!
    redirect_to display_path, notice: I18n.t(:notice_created)
  end

  def update
    @record = LoanResponseSet.find(params[:id])
    authorize @record
    @record.update!(record_params)
    redirect_to display_path, notice: I18n.t(:notice_updated)
  end

  def destroy
    @record = LoanResponseSet.find(params[:id])
    authorize @record
    @record.destroy!
    redirect_to display_path, notice: I18n.t(:notice_deleted)
  end

  private

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def record_params
    params.require(:loan_response_set).permit!
  end

  def display_path
    # redirect to proper path
    admin_loan_path(@record.loan, filter: @record.kind, anchor: "questions")
  end
end
