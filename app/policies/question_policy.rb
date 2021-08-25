class QuestionPolicy < ApplicationPolicy
  def show?
    # As a general rule, anyone is permitted to see any question in the system.
    # There are controller/view-level filters when managing questions or filling out the business plan.
    true
  end

  def create?
    division_admin
  end

  def update?
    division_admin
  end

  def move?
    update?
  end

  def destroy?
    division_admin
  end
end
