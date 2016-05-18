class OrganizationPolicy < ApplicationPolicy
  class Scope < DivisionOwnedScope
  end
end
