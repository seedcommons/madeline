class DataExportPolicy < ApplicationPolicy
  def create?
    any_division_admin?
  end
end
