class ApplicationController < ActionController::API
  before_action :jwt_authenticate!

  private

  def jwt_authenticate!
    payload = extract_payload_from_header
    return invalid_request unless payload
  end

  def extract_payload_from_header
    authorization_header = request.headers['Authorization']
    return nil unless authorization_header

    token = extract_token_from(authorization_header)
    AccessToken.decode(token)
  rescue JWT::DecodeError
    nil
  end

  def invalid_request
    render json: { error: 'Unauthorized' }, status: 401
  end

  def extract_token_from(header)
    matchs = header.match(/\ABearer (.+)\z/)
    matchs[1] if matchs
  end
end
