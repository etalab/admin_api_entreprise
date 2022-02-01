require 'active_support/core_ext/integer/time'

Rails.application.configure do
    config.hosts << "dashboard.entreprise.api.gouv.local"
    config.hosts << "v3-beta.entreprise.api.gouv.local"

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  config.active_job.queue_adapter = :async
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = false

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  config.account_tokens_list_url  = 'https://sandbox.dashboard.entreprise.api.gouv.fr/me/tokens/'
  config.jwt_renewal_url  = 'https://datapass-staging.api.gouv.fr/copy-authorization-request/'
  config.jwt_authorization_request_url  = 'https://datapass-staging.api.gouv.fr/api-entreprise/'
  config.jwt_magic_link_url = 'https://sandbox.dashboard.entreprise.api.gouv.fr/public/tokens/'

  config.redis_database = 'redis://localhost:6379/0'
  config.emails_sender_address = 'support@entreprise.api.gouv.fr'

  # OAuth API Gouv config
  config.oauth_api_gouv_client_id = '4442bfd8caac8e19ff202d33060edcd248592662d5a8098e28b706ba906fe9e0db95ad336c38248f42896db272990b8dfc969d8b8857101dabf9b2ffe7ec49b9'
  config.oauth_api_gouv_issuer = 'https://auth-test.api.gouv.fr'
  config.oauth_api_gouv_baseurl = 'https://auth-test.api.gouv.fr'
  config.oauth_api_gouv_redirect_uri = 'http://localhost:8080/auth_api_gouv_callback'
end
