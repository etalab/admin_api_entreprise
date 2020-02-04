module Request::Operation
  class Authenticate < Trailblazer::Operation
    step :extract_authorization_header
    step :extract_token_from_header
    step :decode_jwt
    step :init_authenticated_user


    def extract_authorization_header(ctx, request:, **)
      ctx[:auth_header] = request.headers['Authorization']
    end

    def extract_token_from_header(ctx, auth_header:, **)
      match = auth_header.match(/\ABearer (.+)\z/)
      ctx[:token] = match[1] if match
    end

    def decode_jwt(ctx, token:, **)
      # TODO move AccessToken logic into JwtApiEntreprise model
      ctx[:jwt_payload] = AccessToken.decode(token)
    rescue JWT::DecodeError
      false
    end

    def init_authenticated_user(ctx, jwt_payload:, **)
      ctx[:authenticated_user] = JwtUser.new(jwt_payload)
    end
  end
end
