module WordpressEmbeddable
  extend ActiveSupport::Concern

  included do
    before_action :update_template
    helper_method :get_division_from_url
  end

  def get_division_from_url
    @get_division_from_url ||= Rails.configuration.x.wordpress_template[:division_urls].select { |key, val|
      request.url.match key
    }.values.first || default_division
  end

  def default_division
    :us
  end

  private
  def update_template
    template_path = "layouts/embedded/wordpress-#{get_division_from_url}"
    return if template_exists?(template_path)
    WordpressTemplate.update(
      division: get_division_from_url,
      base_uri: [request.protocol, request.host_with_port].join
    )
  end
end
