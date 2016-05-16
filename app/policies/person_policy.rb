class PersonPolicy < ApplicationPolicy
  class Scope < DivisionOwnedScope
  end
end
