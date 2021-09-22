module OmniAuth::Strategies
  class ApiGouv < OmniAuth::Strategies::OAuth2
    option :name, :api_gouv

    option :client_options, {
      site: 'https://auth-staging.api.gouv.fr',
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

    private

    def raw_info
      @raw_info ||= access_token.get('/oauth/userinfo').parsed
    end
  end
end
