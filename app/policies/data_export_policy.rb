class DataExportPolicy < ApplicationPolicy
  def index?
    division_member_or_admin(division: record.division)
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  class Scope < Scope
    def resolve
      scope.where(division: user.division.self_and_descendants.pluck(:id))
    end
  end
end
