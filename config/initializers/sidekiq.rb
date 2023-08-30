Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Rails.application.config_for(:redis)[:url] } }

  config.on(:startup) do
    schedule_file = Rails.root.join('config/schedule.yml')

    if File.exist?(schedule_file)
      loaded_conf = YAML.load_file(schedule_file, aliases: true)
    end

    Sidekiq::Cron::Job.load_from_hash(loaded_conf[Rails.env])
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Rails.application.config_for(:redis)[:url] } }
end
