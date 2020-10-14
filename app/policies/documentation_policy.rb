class DocumentationPolicy < ApplicationPolicy
  def index?
    division_admin(division: Division.root)
  end

  def show?
    user.division.self_and_ancestors.include?(record.division) ||
      record.division.ancestors.include?(user.division)
  end
end
