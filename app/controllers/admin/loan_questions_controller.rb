class Admin::LoanQuestionsController < Admin::AdminController
  def index
    authorize CustomFieldSet
    field_sets = CustomFieldSet.where(internal_name: ['loan_criteria', 'loan_post_analysis'])
    @questions = field_sets.map(&:custom_fields).flatten
    @json = ActiveModel::ArraySerializer.new(@questions, each_serializer: LoanQuestionSerializer).to_json
  end
end
