source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'turbo-rails'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.20'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'uri', '1.0.3'

gem 'good_job', '~> 3.99'

gem 'draper'
gem 'ip_anonymizer'
gem 'jwt'
gem 'mailjet'
gem 'mjml-rails'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pundit'
gem 'sitemap_generator'

gem 'pastel'

gem 'rails-i18n'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem 'logstasher'

gem 'interactor'

gem 'chronic'

gem 'sentry-rails'
gem 'sentry-ruby'

gem 'kramdown-parser-gfm'

gem 'algoliasearch-rails'

gem 'listen'

gem 'anchored'

gem 'strong_migrations'

gem 'gaffe'

gem 'pretender'

gem 'kaminari'

gem 'ransack'

gem 'wicked'

gem 'rest-client'
gem 'faraday'
gem 'faraday-gzip'
gem 'faraday-net_http'
gem 'faraday-retry'
gem 'faraday-encoding'

gem 'csv'

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman'
  gem 'bullet'
  gem 'colorize'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'i18n-tasks'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack_session_access'
  gem 'timecop'
  gem 'unindent'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.3'
  gem 'rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'

  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'cuprite'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '7.1.1'
  gem 'rspec-retry'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'super_diff'
  gem 'webmock'
end
