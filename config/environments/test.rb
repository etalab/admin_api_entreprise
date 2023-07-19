require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  config.hosts = []

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

  config.account_tokens_list_url  = 'https://sandbox.dashboard.entreprise.api.gouv.fr/me/jetons/'
  config.token_renewal_url  = 'https://datapass-staging.api.gouv.fr/copy-authorization-request/'
  config.token_authorization_request_url  = 'https://datapass-staging.api.gouv.fr/api-entreprise/'

  # OAuth API Gouv config
  config.oauth_api_gouv_client_id_entreprise = '4442bfd8caac8e19ff202d33060edcd248592662d5a8098e28b706ba906fe9e0db95ad336c38248f42896db272990b8dfc969d8b8857101dabf9b2ffe7ec49b9'
  config.oauth_api_gouv_client_id_particulier = '844e3bff46ebdac9beb18c6cf793dedfdb1776262911b3d927d24871f03e46b38756b5d015d1a693057328d8673408cccf48ef7c5a6e94fa5d101042663fb5b1'
  config.oauth_api_gouv_issuer = 'https://app-test.moncomptepro.beta.gouv.fr'
  config.oauth_api_gouv_baseurl = 'https://app-test.moncomptepro.beta.gouv.fr'
end
