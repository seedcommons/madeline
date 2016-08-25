module DivisionSelectable
  extend ActiveSupport::Concern

  # Represents the division to use when creating new entities.
  def current_division
    selected_division || default_division
  end

  # Division to use for new entities if a division is not specifically selected
  def default_division
    current_user.default_division
  end

  # Represents the current division filter applied to index views.
  def selected_division
    @selected_division ||= (id = selected_division_id) ? Division.find_safe(id) : nil
  end

  # Returns the index grid view conditions filter to be applied.  If a specific division is
  # selected, then restrict to that division and its descendants, otherwise include all divisions
  # which the current user has access to.
  def division_index_filter
    selected = selected_division
    selected ? {division_id: selected.self_and_descendant_ids} : nil
  end

  def selected_division_id
    session[:selected_division_id]
  end

end
