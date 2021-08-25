module QuestionnaireRenderable
  extend ActiveSupport::Concern

  def prep_questionnaire(json: true)
    @attrib = params[:filter] || "criteria"
    @response_set ||= @loan.send(@attrib) || ResponseSet.new(kind: @attrib, loan: @loan)
    @response_set.current_user = current_user
    @root = LoanFilteredQuestion.new(@response_set.question_set.root_group_preloaded, loan: @loan, user: current_user)
    if json
      @questions_json = @root.children.map do |q|
        QuestionSerializer.new(q, selected_division: selected_division)
      end.to_json
    end
  end
end
