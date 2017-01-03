class LoanQuestionPolicy < ApplicationPolicy
  def move?
    update?
  end
end
