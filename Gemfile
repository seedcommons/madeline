source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.1", ">= 5.1.4"
gem "pg", "~> 0.15", "< 0.21.0"
gem "mysql2" # needed for migration of legacy data

# Assets
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2.0"
gem "therubyracer", platforms: :ruby
gem "jquery-rails"
gem "font-awesome-rails"
gem "bootstrap-sass"
gem "momentjs-rails"
gem "fullcalendar-rails"
gem "select2-rails"
gem "rails-backbone"
gem "uri-js-rails" # URI manipulation
gem "bootstrap-datepicker-rails"

# File attachments
gem "carrierwave"
gem "mini_magick"
gem "paperclip", "~> 5.2"

# Authentication / Authorization
gem "devise"
gem "pundit"
gem "rolify"

gem "slim" # Slim template language

gem "delayed_job_active_record"
gem "daemons"

# Internationalization
gem "rails-i18n"
gem "i18n-js", ">= 3.0.0.rc11"
gem "devise-i18n"
gem "route_translator", ">=5.5.3"

# Model hierarchical data
gem "closure_tree"

# Tables
gem "font-awesome-sass", "~> 4.3"
gem "jquery-ui-rails"

# We are using this fork because:
# 1. 'tag_options' no longer valid in rails 5
# 2. AR 'size' method triggers the count query which causes errors in rails 5
gem "wice_grid", git: 'https://github.com/sassafrastech/wice_grid.git', branch: 'rails5'

gem "simple_form"
gem "summernote-rails", "~> 0.8.10.0" # Text editor
gem "gon" # Passing controller data to JS
gem "active_model_serializers" # Generating JSON data
gem "remotipart", "~> 1.2" # File uploads for remote: true forms
gem "goldiloader" # Eager loading
gem "chroma" # Color manipulation
gem "attribute_normalizer" # For normalizing model attribs
gem "exception_notification" # Send email on errors
gem "addressable" # URL handling
gem "quickbooks-ruby"
gem "chronic" # For parsing human readable dates
gem "whenever", "~> 0.9", require: false # Improved syntax for creating cron jobs
gem "amoeba" # Easy cloning of active record objects

group :development, :test do
  # Load environment variables from .env file in development
  gem "dotenv-rails"

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "pry", "0.10.4"
  gem "pry-nav", "0.2.4"
  gem "pry-rails", "0.3.5"

  # Watches for inefficient queries and recommends eager loading
  gem "bullet"

  # Report number of queries in server log
  gem "sql_queries_count"

  # Annotate models & factories
  gem "annotate"

  # Better console printing
  gem "awesome_print"
  gem "hirb"

  # Specs and Test Coverage
  gem "rspec-rails"
  gem "pundit-matchers"
  gem "factory_bot_rails"
  gem "database_cleaner", "~> 1.5"
  gem "faker"
  gem "capybara", "~> 2.0"
  gem "capybara-screenshot", "~> 1.0"
  gem "selenium-webdriver", "~> 2.0"
  gem "poltergeist", "~> 1.0"
  gem "simplecov"

  # Dump data to Rails commands
  gem "seed_dump"
end

group :development do
  # Improve error screens
  gem "better_errors"
  gem "binding_of_caller"

  # Fix db schema conflicts
  gem "fix-db-schema-conflicts"

  # Linting
  gem "rubocop"
  gem "rubocop-rspec"

  # Deployment
  gem "capistrano3-delayed-job", "~> 1.0"
  gem "capistrano", "~> 3.1"
  gem "capistrano-rails", "~> 1.1"
  gem "capistrano-passenger"
  gem "capistrano-rbenv", "~> 2.1"

  # Auto reload browser
  gem "guard-livereload", "~> 2.5", require: false
  gem "rack-livereload"

  gem "term-ansicolor", "~> 1.3.0"

  # Mask password at command line
  gem "highline"
end

group :development, :doc do
  gem "rails-erd"
end
