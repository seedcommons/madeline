class Accounting::TransactionPolicy < ApplicationPolicy
  def index?
    division_admin(division: Division.root)
  end

  # For debugging only
  def new?
    true
  end
end
