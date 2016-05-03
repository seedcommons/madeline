module DivisionHelper

  # List of other divisions which the current user has access to and are allowed to be assigned
  # as a parent to this division.
  def parent_choices(division)
    (current_user.accessible_divisions - division.self_and_descendants) | [division.parent]
  end

  def currency_choices
    Currency.all
  end

end
