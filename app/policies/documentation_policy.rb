class DocumentationPolicy < ApplicationPolicy
  def create?
    any_division_admin?
  end

  def new?
    create?
  end

  def edit?
    create?
  end

  def update?
    edit?
  end

  def show?
    create?
  end
end
