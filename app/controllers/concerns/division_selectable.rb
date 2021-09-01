module DivisionSelectable
  extend ActiveSupport::Concern

  # Represents the current division filter applied to index views.
  # Returns NIL if in 'All Divisions' mode.
  def selected_division
    return @selected_division if defined?(@selected_division)

    @selected_division = selected_division_id ? Division.find(selected_division_id) : nil
  end

  def selected_division_or_root
    selected_division || Division.root
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
