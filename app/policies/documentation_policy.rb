class DocumentationPolicy < ApplicationPolicy
  def show?
    # show if any of the user's divisions match the record's division or any of its ancestors
    user_divisions = user.accessible_division_ids
    record_divisions = record&.division&.self_and_ancestor_ids
    intersection = (user_divisions & record_divisions)
    intersection.present?
  end
end
