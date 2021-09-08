module QuestionnaireRenderable
  extend ActiveSupport::Concern

  def prep_questionnaire(json: true)
    @attrib = params[:filter] || "loan_criteria"
    @response_set ||= ResponseSet.find_by(loan: @loan, kind: @attrib) || ResponseSet.new(kind: @attrib, loan: @loan)
    @root = LoanFilteredQuestion.new(@response_set.question_set.root_group_preloaded, loan: @loan)
    @questions_json = @root.children.map { |q| FilteredQuestionSerializer.new(q) }.to_json if json
  end
end
