module WordpressEmbeddable
  extend ActiveSupport::Concern

  included do
    before_action :check_template
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

  def update
    skip_authorization
    update_template
    redirect_to controller: "loans", action: "index", site: params[:site]
  end

  private

  def check_template
    template_path = "layouts/public/wordpress/#{Rails.env}/wordpress-#{get_division_from_url}"
    update_template unless template_exists?(template_path)
  end

  def update_template
    base_uri = Rails.configuration.x.wordpress_template[:base_uri][get_division_from_url]

    WordpressTemplate.update(
      division: get_division_from_url,
      base_uri: base_uri
    )
  end
end
