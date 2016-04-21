class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Todo: Confirm if there is a better way to handle methods which need to be shared between
  # views and controllers.
  helper_method :selected_division_id
  helper_method :division_select_options

  # Represents the division to use when creating new entities.
  def current_division
    selected_division || default_division
  end

  # Division to uses for new entities if a division is not specifically selected
  def default_division
    # Todo: Return a default division dependent upon current user.
    Division.root
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
    division = selected_division
    division.present? ? {division: division} : nil
  end

  def selected_division_id
    session[:selected_division_id]
  end

  def set_selected_division_id(id)
    session[:selected_division_id] = id
  end

  def division_select_options
    #todo: limit to divisions current user has access to
    (Division.all.map{|d| [d.name, d.id]}).insert(0, ['All', nil])
  end


  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
