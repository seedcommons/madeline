class SettingPolicy < ApplicationPolicy
  def show?
    division_admin(division: Division.root)
  end

  def update?
    division_admin(division: Division.root)
  end
end
