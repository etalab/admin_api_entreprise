source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'sidekiq'
gem 'sidekiq-cron'

gem 'doorkeeper', '~> 4.4.0'
gem 'jwtf', '0.2.0'
gem 'jwt', '~> 2.2.1'
gem 'active_model_serializers', '~> 0.10.0'

gem 'trailblazer', '~> 2.1.0.rc13'
gem 'reform-rails'
gem 'reform', '2.3.0.rc1'
gem 'dry-validation', '~> 0.11.1'

gem 'pundit', '~> 1.1'

gem 'pastel'

gem 'logstasher'

group :development, :test do
  gem 'vcr'
  gem 'webmock'
  gem 'awesome_print'
  gem 'colorize'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'unindent'
  gem 'guard-rspec'
  gem 'faker'
  gem 'timecop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'mina', '~> 1.2'
  gem 'rubocop', require: false
end

group :test do
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'factory_bot_rails'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'shoulda-matchers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
