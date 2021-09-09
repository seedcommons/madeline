module QuestionnaireRenderable
  extend ActiveSupport::Concern

  # Prepares variables for rendering a questionnaire.
  # Some users may set @question_set or @response_set before calling this helper,
  # in which case they will be left alone.
  def prep_questionnaire(json: true)
    @question_sets = QuestionSet.find_for_division(selected_division_or_root)
    @question_set ||= params.key?(:qset) ? QuestionSet.find(params[:qset]) : @question_sets.first
    @response_set ||= ResponseSet.find_or_initialize_by(loan: @loan, question_set: @question_set)
    @root = LoanFilteredQuestion.new(@question_set.root_group_preloaded, loan: @loan)
    @questions_json = @root.children.map { |q| FilteredQuestionSerializer.new(q) }.to_json if json
  end
end
