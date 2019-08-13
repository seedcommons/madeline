class DocumentationPolicy < ApplicationPolicy
  def show?
    user.division.self_and_ancestors.include?(record.division) ||
      record.division.ancestors.include?(user.division)
  end
end
