class DashboardPolicy < ApplicationPolicy
  class Scope < DivisionOwnedScope
  end

  def dashboard?
    true
  end
end
