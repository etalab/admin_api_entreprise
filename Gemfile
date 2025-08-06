source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'anchored'
gem 'bcrypt', '~> 3.1.20'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'chronic'
gem 'csv'
gem 'draper'
gem 'faraday'
gem 'faraday-encoding'
gem 'faraday-gzip'
gem 'faraday-net_http'
gem 'faraday-retry'
gem 'gaffe'
gem 'good_job', '~> 3.99'
gem 'interactor'
gem 'ip_anonymizer'
gem 'jwt', '< 3.0'
gem 'kaminari'
gem 'kramdown-parser-gfm'
gem 'listen'
gem 'logstasher'
gem 'mailjet'
gem 'mjml-rails'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pastel'
gem 'pg'
gem 'pretender'
gem 'puma'
gem 'pundit'
gem 'rack-cors'
gem 'rails', '~> 8.0'
gem 'rails-i18n'
gem 'ransack'
gem 'redis'
gem 'rest-client'
gem 'sass-rails', '>= 6'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sitemap_generator'
gem 'strong_migrations'
gem 'turbo-rails'
gem 'uri', '1.0.3'
gem 'wicked'

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
  gem 'rack-mini-profiler', '~> 4.0'
  gem 'rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'web-console', '>= 4.1.0'

  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'cuprite'
  gem 'faker'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '8.0.1'
  gem 'rspec-retry'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'super_diff'
  gem 'webmock'
end
