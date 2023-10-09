source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1'
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
gem 'bcrypt', '~> 3.1.19'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'sidekiq'
gem 'sidekiq-cron'

gem 'draper'
gem 'ip_anonymizer'
gem 'jwt'
gem 'mailjet'
gem 'pundit'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'sitemap_generator'

gem 'pastel'

gem 'rails-i18n','~> 7.0.8'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem 'logstasher'

gem 'interactor'

gem 'chronic'

gem 'sentry-ruby'
gem 'sentry-rails'

gem 'kramdown-parser-gfm'

gem "algoliasearch-rails"

gem 'listen'

gem 'anchored'

gem 'strong_migrations'

gem 'gaffe'

group :development, :test do
  gem 'awesome_print'
  gem 'colorize'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'unindent'
  gem 'guard-rspec'
  gem 'timecop'
  gem 'rack_session_access'
  gem 'i18n-tasks'
  gem 'brakeman'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.1'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'

  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem "cuprite"
  gem 'webmock'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '6.0.3'
  gem 'rspec-its'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'shoulda-matchers'
  gem 'super_diff'
  gem 'rspec-retry'
end
