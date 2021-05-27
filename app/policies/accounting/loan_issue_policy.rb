class Accounting::LoanIssuePolicy < ApplicationPolicy
  # TODO if we move forward with division-based qb connections, PLTs should belong to
  # a qb division as well as a loan (and PLTs will likely need more refactoring)
  # For now, only root div admins
  def index?
    division_admin(division: Division.root)
  end

  def show?
    division_admin(division: Division.root)
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
