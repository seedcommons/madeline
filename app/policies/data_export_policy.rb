class DataExportPolicy < ApplicationPolicy
  def index?
    division_admin
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  class Scope < Scope
    def resolve
      # Technically the Madeline role system allows a user to be a member of one division and an
      # admin of another. This is not supported in the UI and seems to be overly complex. It
      # should probably be simplified.
      #
      # Here, we just require that the user be admin of their own home division, which is what the system
      # actually does when 'Admin' is selected in the UI. If they are admin of their home division,
      # then we allow them to see DataExports from that division and its descendants.
      #
      # This check is mostly academic since the user won't be able to view the index
      # page in the first place if they don't have admin access for the selected division.
      # But it seems more correct to have it here just in case this Scope gets used in other places
      # in the future.
      return scope.none unless user.profile.access_role == :admin

      scope.where(division: user.division.self_and_descendants.pluck(:id))
    end
  end
end
