module OmniAuth::Strategies
  class APIGouv < OmniAuth::Strategies::OAuth2
    option :name, :api_gouv

    option :client_options, {
      site: Rails.configuration.oauth_api_gouv_baseurl,
      authorize_url: '/oauth/authorize',
      callback_path: '/auth/api_gouv/callback',
      auth_scheme: :basic_auth,
      ssl: {
        verify: !Rails.env.development?
      }
    }

    option :scope, 'openid email'

    uid { raw_info['sub'] }

    info { raw_info }

    def callback_url
      full_host + callback_path
    end

    private

    def raw_info
      @raw_info ||= access_token.get('/oauth/userinfo').parsed
    end
  end
end

OmniAuth::Strategies::ApiGouv = OmniAuth::Strategies::APIGouv
