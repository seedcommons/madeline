class LoanQuestionPolicy < ApplicationPolicy
  def move?
    update?
  end

  # Users can see loan questions from their division, any of its ancestors, and any of its descendents.
  def show?
    user.division.self_and_ancestors.include?(record.division) ||
      record.division.ancestors.include?(user.division)
  end
end
