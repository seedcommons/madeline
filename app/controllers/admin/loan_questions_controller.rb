class Admin::LoanQuestionsController < Admin::AdminController
  def index
    authorize CustomFieldSet
    field_set = params[:field_set] || 'loan_criteria'
    @questions = CustomFieldSet.find_by(internal_name: field_set).try(:custom_fields)
  end
end
