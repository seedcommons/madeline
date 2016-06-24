class CustomFieldPolicy < ApplicationPolicy
  def move?
    update?
  end
end
