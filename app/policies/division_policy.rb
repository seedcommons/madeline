class DivisionPolicy < ApplicationPolicy
  def index?
    division_member_or_admin(division: @record)
  end

  def show?
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

  def select?
    show?
  end

  class Scope < Scope
    def resolve
      scope.where(id: accessible_ids)
    end

    # This merges in child divisions of the divisions for which a user has been specifically
    # granted access.
    def accessible_ids
      all_ids = base_accessible_ids.map do |id|
        division = Division.find_safe(id)
        division.self_and_descendants.pluck(:id) if division
      end
      all_ids.flatten.uniq.compact
    end

    # List of division hierarchy nodes for which user has been granted access.
    def base_accessible_ids
      user.roles.where(resource_type: :Division, name: [:member, :admin]).pluck(:resource_id).uniq
    end
  end

end
