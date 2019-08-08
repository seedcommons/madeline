class DocumentationPolicy < ApplicationPolicy
  def show?
    # a user may see documentations that belong to any of their divisions or any ancestors of their division
    user_divisions = user.accessible_division_ids + user.division.self_and_ancestor_ids
    user_divisions.include?(record.division.id)
  end

  def update?
    # allow edit if any of the user's divisions match the record's division or any of its ancestors
    user_divisions = user.accessible_division_ids
    record_divisions = record&.division&.self_and_ancestor_ids
    intersection = (user_divisions & record_divisions)
    intersection.present?
  end
end
