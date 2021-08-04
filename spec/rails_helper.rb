# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "capybara/rails"
require "capybara/rspec"
require "devise"
require "pundit/rspec"
require "pundit/matchers"
require "sidekiq/testing"

# Automatically downloads chromedriver, which is used use for JS feature specs
require "webdrivers/chromedriver"

# So we don't need to prepare test db every time
ActiveRecord::Migration.maintain_test_schema!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.example_status_persistence_file_path = Rails.root.join("tmp/spec/failures.txt")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:each) do |example|
    traits = []
    traits << :with_accounts if example.metadata[:accounting]
    # Create root division
    create(:division, *traits, parent: nil, name: "-", description: "Root", public: false)
  end

  config.after(:each) do
    # fix for weird database cleansing situation
    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    if Rails.env.test?
      tmp_uploads_path = Rails.root.join("public/uploads/tmp")
      test_uploads_path = Rails.root.join("public/uploads/test")
      FileUtils.rm_rf(Dir[tmp_uploads_path])
      FileUtils.rm_rf(Dir[test_uploads_path])
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include SystemSpecHelpers, type: :system
  config.include DownloadHelpers, type: :system
  config.include FactoryBot::Syntax::Methods
  config.include FactorySpecHelpers
  config.include GeneralSpecHelpers
  config.include QuestionSpecHelpers, type: :model
  config.include ProjectSpecHelpers, type: :model
end

def record_class(record_type)
  record_type.to_s.camelize.constantize
end
