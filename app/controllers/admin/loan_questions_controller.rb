class Admin::LoanQuestionsController < Admin::AdminController
  before_action :set_loan_question, only: [:show, :edit, :update, :destroy]

  def index
    authorize CustomField
    @questions = CustomField
        .joins(:custom_field_set)
        .where(custom_field_sets: {internal_name: ['loan_criteria', 'loan_post_analysis']})
    @json = ActiveModel::Serializer::CollectionSerializer.new(@questions.roots).to_json
  end

  def edit
    authorize @loan_question
    render partial: 'edit_modal'
  end

  private

    def set_loan_question
      @loan_question = CustomField.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def loan_question_params
      params[:loan_question]
    end
end
