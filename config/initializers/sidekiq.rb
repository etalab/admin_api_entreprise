def load_sidekiq_cron_jobs
  schedule_file = Rails.root.join('config/schedule.yml')

  if File.exist?(schedule_file)
    loaded_conf = YAML.load_file(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(loaded_conf[Rails.env])
  end
end


Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Rails.configuration.redis_database } }

  load_sidekiq_cron_jobs
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Rails.configuration.redis_database } }
end
