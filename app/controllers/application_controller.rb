class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_division_from_url
    @get_division_from_url ||= Rails.configuration.wordpress_template[:division_urls].select { |key, val|
      request.url.match key
    }.values.first || default_division
  end
  helper_method :get_division_from_url

  def default_division
    :us
  end

  def update_template
    WordpressTemplate.update(get_division_from_url)
    redirect_to root_path
  end
end
