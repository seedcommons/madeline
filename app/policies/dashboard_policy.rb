class DashboardPolicy < ApplicationPolicy
  class Scope < DivisionOwnedScope
    def dashboard?
      true
    end
  end
end
