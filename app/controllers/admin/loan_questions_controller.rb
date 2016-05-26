class Admin::LoanQuestionsController < Admin::AdminController
  def index
    @questions = CustomFieldSet.find_by(internal_name: params[:field_set]).custom_fields
  end
end
