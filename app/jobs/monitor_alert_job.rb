require 'open-uri'
require 'net/http'

class MonitorAlertJob < ApplicationJob
  def perform
    %w[entreprise particulier].each do |api|
      alert_if_monitors_down(api)
    end
  end

  private

  def alert_if_monitors_down(api)
    down_monitors = find_down_monitors(api)

    return if down_monitors.empty?

    down_monitors.each { |monitor| send_alert(monitor) }
  end

  def find_down_monitors(api)
    monitors = []

    status_page_data(api).dig('sections', 'blocks')&.each do |block|
      block['services']&.each do |service|
        monitors << service['alias'] if service['status'] == 'outage'
      end
    end

    monitors
  end

  def send_alert(monitor_name)
    uri = URI.parse(webhook_target_url)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = alert_message(monitor_name)
      http.request(request)
    end
  end

  def status_page_data(api)
    JSON.parse(status_page_body(api))
  end

  def status_page_body(api)
    URI.parse(status_page_url(api)).open(open_timeout: 10, read_timeout: 10).read
  end

  def status_page_url(api)
    "https://api-#{api}.hyperping.app/api/config?hostname=api-#{api}.hyperping.app"
  end

  def webhook_target_url
    Rails.application.credentials.mattermost_webhook_url
  end

  def alert_message(monitor_name)
    { text: "⛈  #{dev_handles.join(' ')} Reminder: the monitor #{monitor_name} is still down." }.to_json
  end

  def dev_handles
    ['@samuel']
  end
end
