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
    # @response_set_from_db = @response_set.attributes.symbolize_keys.merge(updater_name: @response_set.updater.try(:name))
    @response_set_from_db = [:updater, :updated_at, :lock_version].map { |i| [i, @response_set.send(i)] }.to_h

    adjusted_params = response_set_params.merge(updater_id: current_user.id)
    adjusted_params[:lock_version] = adjusted_params.delete(:new_lock_version) if params[:overwrite]

    @response_set.update!(adjusted_params) unless params[:discard]
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
    admin_loan_tab_path(@response_set.loan, tab: 'questions', filter: @response_set.kind)
  end
end
