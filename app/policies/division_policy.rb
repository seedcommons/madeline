class DivisionPolicy < ApplicationPolicy
  def index?
    # Require admin role on at least one division to allow access to index view
    any_division_admin?
  end

  def show?
    division_member_or_admin(division: @record)
  end

  def create?
    # Need to let record with missing parent pass through the policy check so a validation
    # message can be presented to the user.
    # Todo: Confirm if there a better approach here?
    return true unless @record.parent
    division_admin(division: @record.parent)
  end

  def update?
    division_admin(division: @record) && !@record.root?
  end

  def destroy?
    division_admin(division: @record.parent) && !@record.root? && !@record.has_noncascading_owned_records?
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
