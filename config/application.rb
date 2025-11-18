require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdminApientreprise
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = 'Europe/Paris'
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr

    config.middleware.insert_after ActionDispatch::RemoteIp, IpAnonymizer::HashIp,
      key: Rails.application.credentials.ip_anonymizer_key

    config.active_job.queue_adapter = :good_job
    config.active_job.queue_name_prefix = "admin_api_entreprise_#{Rails.env}"

    config.action_mailer.deliver_later_queue_name = :default
    config.action_mailer.preview_paths << "#{Rails.root}/spec/mailers/previews"

    config.assets.prefix = '/assets'
    config.assets.version = 'v3'

    config.cache_store = :redis_cache_store, config_for(:cache_redis).merge(
      namespace: "admin_api_entreprise_cache_#{Rails.env}_#{Time.now.to_i}",
      expires_in: (7 * 24 * 60 * 60)
    )

    config.generators do |g|
      g.test_framework :rspec
      g.stylesheets false
      g.javascripts false
    end
  end
end
