require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdminApientreprise
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.

    # Set dry-validation as the validation engine for reform
    config.reform.validations = :dry

    config.time_zone = 'Europe/Paris'
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr

    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "admin_api_entreprise_#{Rails.env}"

    config.action_mailer.deliver_later_queue_name = :default
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
  end
end
