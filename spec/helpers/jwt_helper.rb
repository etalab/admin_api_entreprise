module JWTHelper
  def extract_payload_from(base64_token)
    base64_payload = base64_token.split('.')[1]
    payload = Base64.urlsafe_decode64(base64_payload)
    JSON.parse(payload, symbolize_names: true)
  end
end
