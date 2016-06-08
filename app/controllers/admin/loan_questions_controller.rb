class Admin::LoanQuestionsController < Admin::AdminController
  def index
    authorize CustomFieldSet
    @questions = CustomField
        .joins(:custom_field_set)
        .where(custom_field_sets: {internal_name: ['loan_criteria', 'loan_post_analysis']})
    @json = ActiveModel::Serializer::CollectionSerializer.new(@questions.roots).to_json
  end
end
