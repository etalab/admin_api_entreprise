class HealthcheckJob < ApplicationJob
  def perform
    return unless frontal_production?

    http = Net::HTTP.new(healthcheck_uri.host, healthcheck_uri.port)

    http.use_ssl = true if healthcheck_uri.scheme == 'https'

    http.head(healthcheck_uri.path)
  end

  private

  def frontal_production?
    Rails.env.production? &&
      ENV['FRONTAL'] == 'true'
  end

  def healthcheck_uri
    @healthcheck_uri ||= URI(healthcheck_url)
  end

  def healthcheck_url
    Rails.application.credentials.healthcheck_url
  end
end
