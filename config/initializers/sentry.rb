Sentry.init do |config|
  config.dsn = ::Rails.application.credentials.sentry_dsn

  config.breadcrumbs_logger = [:active_support_logger]
  config.enabled_environments = %w[production staging]

  config.traces_sample_rate = 1.0
end
