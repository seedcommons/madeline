source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'pg', '~> 0.15'

# Assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'bootstrap-sass'
gem 'momentjs-rails'
gem 'fullcalendar-rails'

# Authentication / Authorization
gem 'devise'

# Pagination
gem 'will_paginate', '~> 3.0.4'
gem 'will_paginate-bootstrap'

# Remove UTF8 parameter from GET forms
gem 'utf8_enforcer_workaround'

# Slim template language
gem 'slim'

# Cron jobs
gem 'whenever', require: false

# Internationalization
gem 'rails-i18n'

# Translate urls
gem 'route_translator'

# Model hierarchical data
gem 'closure_tree'

# needed for migration of legacy data
gem 'mysql2'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Watches for inefficient queries and recommends eager loading
  gem 'bullet'

  # Report number of queries in server log
  gem 'sql_queries_count'

  # Specs and Test Coverage
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'faker'
  gem 'capybara'
  gem 'simplecov'
end

group :development do
  # Improve error screens
  gem 'better_errors'
  gem 'binding_of_caller'

  # Fix db schema conflicts
  gem 'fix-db-schema-conflicts'

  # Deployment
  # gem 'capistrano',  '~> 3.1'
  # gem 'capistrano-rails', '~> 1.1'
  # gem 'capistrano-passenger'
end

group :doc do
  gem 'rails-erd'
end
