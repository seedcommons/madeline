class DataExportPolicy < ApplicationPolicy
  def index?
    division_admin(division: Division.root)
  end

  def show?
    division_admin(division: Division.root)
  end

  def new?
    division_admin(division: Division.root)
  end

  def create?
    division_admin(division: Division.root)
  end

  def index?
    true
  end
end
