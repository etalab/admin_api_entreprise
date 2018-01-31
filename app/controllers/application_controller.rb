class ApplicationController < ActionController::API
  include Pundit
  before_action :jwt_authenticate!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # TODO move this into a Request::Authenticate operation ?
  def jwt_authenticate!
    extract_payload_from_header
    return unauthorized unless @auth_payload

    @pundit_user = JwtUser.new(@auth_payload[:uid])
  end

  def extract_payload_from_header
    authorization_header = request.headers['Authorization']
    return nil unless authorization_header

    token = extract_token_from(authorization_header)
    @auth_payload = AccessToken.decode(token)
  rescue JWT::DecodeError
    nil
  end

  def unauthorized
    render json: { error: 'Unauthorized' }, status: 401
  end

  def extract_token_from(header)
    matchs = header.match(/\ABearer (.+)\z/)
    matchs[1] if matchs
  end

  # Method called by Pundit to get the current user of the request
  # @pundit_user is the first argument passed to policies
  def pundit_user
    @pundit_user
  end

  def user_not_authorized
    render json: { errors: 'Forbidden' }, status: 403
  end
end
