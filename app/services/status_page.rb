require 'open-uri'

class StatusPage
  attr_reader :api

  def initialize(namespace)
    @api = namespace.split('_').last
  end

  def current_status
    case raw_current_status
    when 'up'
      :up
    when 'outage'
      :has_issues
    when 'maintenance'
      :maintenance
    else
      :undefined
    end
  rescue StandardError
    :undefined
  end

  private

  def raw_current_status
    cache.read(cache_key) ||
      retrieve_from_status_page
  end

  def retrieve_from_status_page
    status = page_config_data['globals']['topLevelStatus']['status']

    cache.write(cache_key, status, expires_in: 5.minutes.to_i)

    status
  end

  def page_config_data
    JSON.parse(
      page_config_data_body
    )
  end

  def page_config_data_body
    URI.parse(page_config_data_url).open.read
  end

  def page_config_data_url
    "https://api-#{api}.hyperping.app/api/config?hostname=api-#{api}.hyperping.app"
  end

  def cache_key
    "api_#{api}_status_page_current_status"
  end

  def cache
    @cache ||= Rails.cache
  end
end
