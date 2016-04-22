class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :selected_division_id
  helper_method :division_select_options

  # Represents the division to use when creating new entities.
  def current_division
    selected_division || default_division
  end

  # Division to uses for new entities if a division is not specifically selected
  def default_division
    current_user.default_division
  end

  # Represents the current division filter applied to index views.
  def selected_division
    id = selected_division_id
    if id
      Division.find_safe(id)
    else
      nil
    end
  end

  def division_index_filter
    selected = selected_division
    ids = selected ? selected.self_and_descendant_ids : current_user.accessible_division_ids
    {division: ids}
  end

  def selected_division_id
    session[:selected_division_id]
  end

  def set_selected_division_id(id)
    id = nil if id.blank?
    session[:selected_division_id] = id
  end

  def division_select_options
    [['All', nil]].concat(current_user.accessible_divisions.map{ |d| [d.name, d.id] })
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
