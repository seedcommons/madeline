class WordpressController < ApplicationController
  def rails_template
    render file: Rails.root.join('spec', 'fixtures', 'wordpress-rails.html'), layout: false
  end
end
