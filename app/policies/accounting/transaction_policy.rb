class Accounting::TransactionPolicy < ApplicationPolicy
  def index?
    division_admin(division: Division.root)
  end

  def show?
    division_admin(division: Division.root)
  end

  def update?
    division_admin(division: Division.root)
  end
end
