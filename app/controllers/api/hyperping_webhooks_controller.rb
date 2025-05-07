class API::HyperpingWebhooksController < APIController
  MONITORED_URLS = [
    'https://api-entreprise.v2.datapass.api.gouv.fr/',
    'https://api-entreprise.v2.datapass.api.gouv.fr/api/frontal',
    'https://back.datapass.api.gouv.fr/api/ping',
    'https://datapass.api.gouv.fr/',
    'https://entreprise.api.gouv.fr/',
    'https://entreprise.api.gouv.fr/api/frontal',
    'https://entreprise.api.gouv.fr/v3/ping',
    'https://quotient-familial.numerique.gouv.fr/',
    'https://suchdevblog.com/test_page.html'
  ].freeze

  def create
    if webhook_params['event'] == 'down' && MONITORED_URLS.include?(webhook_params['check']['url'])
      notification = json_message_alert_down(webhook_params['check']['name'])
      notify_mattermost(notification)
      render json: { success: true }, status: :ok
    else
      render json: { success: true, message: 'Event ignored' }, status: :ok
    end
  end

  private

  def notify_mattermost(notification)
    Net::HTTP.start(mattermost_webhook_uri.host, mattermost_webhook_uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(mattermost_webhook_uri.request_uri, 'Content-Type' => 'application/json')
      request.body = notification
      http.request(request)
    end
  end

  def json_message_alert_down(service_name)
    { text: "@all Alert! #{service_name} is down" }.to_json
  end

  def mattermost_webhook_uri
    URI(Rails.application.credentials.mattermost_webhook_url)
  end

  def webhook_params
    params.permit(:event, check: %i[id name url location]).to_h
  end
end
