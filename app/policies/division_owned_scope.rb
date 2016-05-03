class DivisionOwnedScope < ApplicationPolicy::Scope

  def resolve
    scope.where(division_id: user.accessible_division_ids)
  end

end
