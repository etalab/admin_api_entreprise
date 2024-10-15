class HubEEAPIAuthentication < AbstractHubEEAPIClient
  def access_token
    http_connection.post(
      auth_url,
      'grant_type=client_credentials&scope=ADMIN',
      {
        'Authorization' => "Basic #{encoded_client_id_and_secret}"
      }
    ).body['access_token']
  end

  private

  def auth_url
    Rails.application.credentials.hubee_auth_url
  end

  def encoded_client_id_and_secret
    Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
  end

  def http_connection(&block)
    @http_connection ||= super do |conn|
      conn.response :json
      yield(conn) if block
    end
  end
end
