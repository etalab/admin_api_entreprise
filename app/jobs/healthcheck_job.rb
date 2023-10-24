class HealthcheckJob < ApplicationJob
  def perform
    http = Net::HTTP.new(healthcheck_uri.host, healthcheck_uri.port)

    http.use_ssl = true if healthcheck_uri.scheme == 'https'

    http.head('/')
  end

  private

  def healthcheck_uri
    @healthcheck_uri ||= URI(healthcheck_url)
  end

  def healthcheck_url
    Rails.application.credentials.healthcheck_url
  end
end
