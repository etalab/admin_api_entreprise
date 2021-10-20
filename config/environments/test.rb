require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false
  config.action_view.cache_template_loading = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  # config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.active_job.queue_adapter = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.middleware.use RackSessionAccess::Middleware

  config.account_tokens_list_url  = 'https://sandbox.dashboard.entreprise.api.gouv.fr/me/tokens/'
  config.jwt_renewal_url  = 'https://datapass-staging.api.gouv.fr/copy-authorization-request/'
  config.jwt_authorization_request_url  = 'https://datapass-staging.api.gouv.fr/api-entreprise/'
  config.jwt_magic_link_url = 'https://sandbox.dashboard.entreprise.api.gouv.fr/public/tokens/'

  config.redis_database = 'redis://localhost:6379/0'
  config.emails_sender_address = 'support@entreprise.api.gouv.fr'

  # OAuth API Gouv config
  config.oauth_api_gouv_client_id = '4442bfd8caac8e19ff202d33060edcd248592662d5a8098e28b706ba906fe9e0db95ad336c38248f42896db272990b8dfc969d8b8857101dabf9b2ffe7ec49b9'
  config.oauth_api_gouv_issuer = 'https://auth-staging.api.gouv.fr'
  config.oauth_api_gouv_baseurl = 'https://auth-staging.api.gouv.fr'
  config.oauth_api_gouv_redirect_uri = 'http://localhost:8080/auth_api_gouv_callback'
end
