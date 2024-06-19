# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  def access_token
    http_connection.post(
      'https://api.insee.fr/token',
      'grant_type=client_credentials',
      {
        'Authorization' => "Basic #{encoded_client_id_and_secret}"
      }
    ).body['access_token']
  end

  private

  def encoded_client_id_and_secret
    Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
  end
end
