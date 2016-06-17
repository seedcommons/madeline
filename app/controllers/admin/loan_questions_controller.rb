class Admin::LoanQuestionsController < Admin::AdminController
  include TranslationSaveable
  before_action :set_loan_question, only: [:show, :edit, :update, :destroy, :move]

  def index
    authorize CustomField
    @questions = CustomField
        .joins(:custom_field_set)
        .where(custom_field_sets: {internal_name: ['loan_criteria', 'loan_post_analysis']})
    @json = ActiveModel::Serializer::CollectionSerializer.new(@questions.roots).to_json
  end

  def edit
    render partial: 'edit_modal'
  end

  def update
    if @loan_question.update(loan_question_params)
      render json: @loan_question.reload
    else
      render partial: 'edit_modal', status: :unprocessable_entity
    end
  end

  def move
    target = CustomField.find(params[:target])
    method = case params[:relation]
      when 'before' then :prepend_sibling
      when 'after' then :append_sibling
      when 'inside' then :prepend_child
    end

    target.send(method, @loan_question)
    head :no_content
  rescue
    flash.now[:error] = I18n.t('loan_questions.move_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  private

    def set_loan_question
      @loan_question = CustomField.find(params[:id])
      authorize @loan_question
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def loan_question_params
      params.require(:custom_field).permit(:label, :data_type, :parent_id, :position, *translation_params(:label))
    end
end
