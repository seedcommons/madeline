class TaskPolicy < ApplicationPolicy
  def index?
    any_division_admin?
  end
end
