module Documentable
  extend ActiveSupport::Concern

  included do
    before_action :set_documentations
  end

  def set_documentations
    @documentations_by_html = Documentation.where(
      calling_controller: controller_name, # name of current controller
    ).index_by(&:html_identifier) # creates a hash
  end
end
