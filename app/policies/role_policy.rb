class RolePolicy < ApplicationPolicy
  def index?
    division_admin
  end

  def show?
    division_admin
  end

  def create?
    division_admin
  end

  def update?
    division_admin
  end

  def delete?
    division_admin
  end
end
