# Configuration for simplecov
# Test coverage options (activated only if rspec is run without arguments)
if ARGV.grep(/spec\.rb/).empty? || ENV['CI'] || ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]
  )

  SimpleCov.start 'rails' do
    add_filter 'app/jobs/application_job.rb'
    add_filter 'app/mailers/application_mailer.rb'
    add_filter 'lib/tasks/'
    add_filter 'lib/mailer_previews/'
  end
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'super_diff/rspec-rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.

# Require helpers files containing factories
Rails.root.glob('spec/helpers/**/*.rb').each { |f| require f }
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
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

  # Include factory_bot methods into test suite
  config.include FactoryBot::Syntax::Methods

  config.include FriendlyDateHelper

  # Include helpers / support accurately for each spec type
  config.include SpecsHelper
  config.include FeatureHelper, type: :feature
  config.include ExternalUrlHelper, type: :feature
  config.include FixturesHelpers
  config.include INSEESireneAPIMocks

  config.around(:each, :js) do |example|
    example.run_with_retry retry: example.metadata[:retry] || 3
  end

  config.before(:each, type: :feature) do
    stub_request(:get, %r{entreprise\.api\.gouv\.fr/ping}).to_return(status: 200)
    stub_request(:get, %r{particulier\.api\.gouv\.fr/api/.*/ping$}).to_return(status: 200)
  end

  config.before do
    Rails.cache.clear
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
