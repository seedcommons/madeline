class DivisionPolicy < ApplicationPolicy
  def index?
    division_member_or_admin(division: @record)
  end

  def create?
    division_admin(division: @record)
  end

  def update?
    division_admin(division: @record)
  end

  def destroy?
    division_admin(division: @record)
  end
end
