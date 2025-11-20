# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  def access_token
    http_connection.post(
      'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token',
      {
        'grant_type' => 'password',
        'client_id' => client_id,
        'client_secret' => client_secret,
        'username' => username,
        'password' => password
      }.to_query
    ).body['access_token']
  end

  protected

  def http_connection
    super do |conn|
      conn.request :retry, retry_options
      conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    end
  end

  def retry_options
    {
      max: 5,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: [
        Faraday::ConnectionFailed,
        Faraday::TimeoutError,
        Faraday::ParsingError,
        Faraday::ClientError,
        Faraday::ServerError,
        Faraday::UnauthorizedError
      ]
    }
  end

  private

  def client_id
    Rails.application.credentials.insee_client_id
  end

  def client_secret
    Rails.application.credentials.insee_client_secret
  end

  def username
    Rails.application.credentials.insee_username
  end

  def password
    Rails.application.credentials.insee_password
  end
end
