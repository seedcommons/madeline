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

  def update
    authorize @loan_question

    respond_to do |format|
      if @loan_question.update(loan_question_params)
        format.json { render json: @loan_question.reload }
      else
        # format.html { render action: 'edit' }
        # format.json { render json: @loan_question.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_loan_question
      @loan_question = CustomField.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def loan_question_params
      params.require(:custom_field).permit(:label, :data_type, :parent_id, :position)
    end

    #todo: factor out into a concern as we implement other translatable forms
    def translations_params(locales)
      translation_params_list = locales.map { |l| %I(locale_#{l} details_#{l} summary_#{l}) }.flatten
      result = params.require(:loan_question).permit(translation_params_list + [:deleted_locales])
      # note, the 'deleted_locales' param is JSON encoded because it was easier to treat as a single field at the form level
      result[:deleted_locales] = JSON.parse(result[:deleted_locales])
      result
    end
end
