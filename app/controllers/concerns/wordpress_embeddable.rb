module WordpressEmbeddable
  extend ActiveSupport::Concern

  included do
    before_action :update_template
    helper_method :get_division_from_url
    layout "public/wordpress"
  end

  def default_division
    :us
  end

  def get_division_from_url
    division_urls = Rails.configuration.x.wordpress_template[:division_urls]
    matching = division_urls.select { |expression, _| request.url.match expression }
    division = matching.values.first
    division || default_division
  end

  private

  def update_template
    template_path = "layouts/public/wordpress/#{Rails.env}/wordpress-#{get_division_from_url}"
    return if template_exists?(template_path)

    base_uri = Rails.configuration.x.wordpress_template[:base_uri][get_division_from_url]

    WordpressTemplate.update(
      division: get_division_from_url,
      base_uri: base_uri
    )
  end
end
