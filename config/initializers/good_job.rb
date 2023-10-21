Rails.application.configure do
  config.good_job.enable_cron = true
  config.good_job.cron = Rails.application.config_for(:schedule)
  config.good_job.dashboard_default_locale = :fr
  config.good_job.logger = ActiveSupport::Logger.new(Rails.root.join('log', 'good_job.log'))
end
