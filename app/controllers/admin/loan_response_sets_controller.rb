class Admin::LoanResponseSetsController < Admin::AdminController
  include QuestionnaireRenderable

  def create
    @response_set = LoanResponseSet.new(response_set_params)
    authorize @response_set
    @response_set.save!
    redirect_to display_path, notice: I18n.t(:notice_created)
  end

  def update
    @response_set = LoanResponseSet.find(params[:id])
    authorize @response_set

    @response_set.update!(response_set_params)
    redirect_to display_path, notice: I18n.t(:notice_updated)
  rescue ActiveRecord::StaleObjectError
    @conflict = true
    @tab = 'questions'
    @loan = @response_set.loan
    prep_questionnaire
    render 'admin/loans/show'

    # flash[:conflict] = true
    # flash[:response_set] = @response_set
    # redirect_to display_path
  end

  def destroy
    @response_set = LoanResponseSet.find(params[:id])
    authorize @response_set
    @response_set.destroy!
    redirect_to display_path, notice: I18n.t(:notice_deleted)
  end

  private

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def response_set_params
    params.require(:loan_response_set).permit!
  end

  def display_path
    admin_loan_path(@response_set.loan) + "/questions?filter=#{@response_set.kind}"
  end
end
