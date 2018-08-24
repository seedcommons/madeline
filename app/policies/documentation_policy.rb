class DocumentationPolicy < ApplicationPolicy
  def create?
    any_division_admin?
  end

  def edit?
    create?
  end

  def update?
    edit?
  end

  def show?
    any_division_member_or_admin?
  end
end
