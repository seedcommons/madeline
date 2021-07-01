require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine" # We use carrierwave for now
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine" # We don't use action cable
require "sprockets/railtie"
# require "rails/test_unit/railtie" # We use rspec

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MadelineSystem
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Additional paths to autoload
    config.eager_load_paths << Rails.root.join("lib")

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Eastern Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.default_url_options = { host: ENV["MADELINE_HOSTNAME"] }

    # We have very many optional belongs_to's, don't want to label them all right now.
    config.active_record.belongs_to_required_by_default = false

    config.generators do |g|
      g.fixture_replacement :factory_bot, suffix: "factory"
    end
  end

  # This seems to be required for proper rendering of all wice_grid views.
  # (Without, view contents is all html escaped.)
  Slim::Engine.set_options pretty: true, sort_attrs: false
end

puts "Rails.env: #{Rails.env}"
puts "database: #{MadelineSystem::Application.config.database_configuration[::Rails.env]['database']}"
