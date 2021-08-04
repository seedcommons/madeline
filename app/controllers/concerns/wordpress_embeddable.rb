module WordpressEmbeddable
  extend ActiveSupport::Concern

  included do
    before_action :check_template
    helper_method :layout_site
    layout "public/wordpress"
  end

  def layout_site
    if params[:site].in?(Loan::URL_DIVISIONS)
      params[:site]
    else
      raise AbstractController::ActionNotFound
    end
  end

  def update
    skip_authorization
    check_template
    redirect_to controller: "loans", action: "index", site: params[:site]
  end

  private

  def check_template
    template_path = "layouts/public/wordpress/#{Rails.env}/wordpress-#{layout_site}"
    update_template unless template_exists?(template_path)
  end

  def update_template
    WordpressTemplate.update(division: layout_site.to_sym)
  end
end
