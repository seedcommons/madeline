module QuestionnaireRenderable
  extend ActiveSupport::Concern

  def prep_questionnaire
    @attrib = params[:filter] || "criteria"
    @response_set ||= @loan.send(@attrib) || LoanResponseSet.new(kind: @attrib, loan: @loan)
    @roots = @response_set.loan_question_set.root_group_preloaded
    @questions_json = @roots.children_applicable_to(@loan).map do |i|
      LoanQuestionSerializer.new(i, loan: @loan)
    end.to_json
  end
end
