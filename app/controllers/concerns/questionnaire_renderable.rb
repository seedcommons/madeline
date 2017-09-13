module QuestionnaireRenderable
  extend ActiveSupport::Concern

  def prep_questionnaire(json: true)
    @attrib = params[:filter] || "criteria"
    @response_set ||= @loan.send(@attrib) || LoanResponseSet.new(kind: @attrib, loan: @loan)
    @root = LoanFilteredQuestion.new(@response_set.loan_question_set.root_group_preloaded, loan: @loan)
    @top_level_questions = @root.children
    @questions_json = @top_level_questions.map { |q| LoanQuestionSerializer.new(q) }.to_json if json
  end
end
