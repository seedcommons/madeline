class DocumentationPolicy < ApplicationPolicy
  def create?
    # TODO: determine authorization
    true
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def show?
    create?
  end
end
