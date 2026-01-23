OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

module ProConnectConfig
  module_function

  def host(type)
    case Rails.env
    when 'development', 'test'
      port = ENV['DOCKER'].present? ? 5000 : 3000
      "http://#{type}.api.localtest.me:#{port}"
    when 'sandbox', 'staging'
      "https://#{Rails.env}.#{type}.api.gouv.fr"
    when 'production'
      "https://#{type}.api.gouv.fr"
    end
  end

  def client_id
    Rails.application.credentials.proconnect_client_id
  end

  def client_secret
    Rails.application.credentials.proconnect_client_secret
  end

  def domain
    Rails.application.credentials.proconnect_url
  end

  def redirect_uri(type)
    "#{host(type)}/auth/proconnect_api_#{type}/callback"
  end

  def scope
    'openid given_name usual_name email uid idp_id siret phone'
  end
end

module OmniAuth
  module Strategies
    class Proconnect
      MFA_ACR_VALUES = [
        'eidas2',
        'eidas3',
        'https://proconnect.gouv.fr/assurance/self-asserted-2fa',
        'https://proconnect.gouv.fr/assurance/consistency-checked-2fa'
      ].freeze

      def self.authorization_uri_with_mfa(type, session:, login_hint:)
        new_state = SecureRandom.hex(16)
        new_nonce = SecureRandom.hex(16)
        session['omniauth.state'] = new_state
        session['omniauth.nonce'] = new_nonce

        params = {
          response_type: 'code',
          client_id: ProConnectConfig.client_id,
          redirect_uri: ProConnectConfig.redirect_uri(type),
          scope: ProConnectConfig.scope,
          state: new_state,
          nonce: new_nonce,
          login_hint: login_hint,
          claims: mfa_claims.to_json
        }

        URI(authorization_endpoint).tap { |uri|
          uri.query = URI.encode_www_form(params)
        }.to_s
      end

      def self.mfa_claims
        {
          id_token: {
            amr: { essential: true },
            acr: { essential: true, values: MFA_ACR_VALUES }
          }
        }
      end

      def self.authorization_endpoint
        @authorization_endpoint ||= discovered_configuration['authorization_endpoint']
      end

      def self.discovered_configuration
        @discovered_configuration ||= Faraday.new(url: ProConnectConfig.domain) { |c|
          c.response :json
        }.get('.well-known/openid-configuration').body
      end

      private

      def authorization_uri
        URI(discovered_configuration['authorization_endpoint']).tap do |endpoint|
          endpoint.query = URI.encode_www_form(
            response_type: 'code',
            client_id: options[:client_id],
            redirect_uri: options[:redirect_uri],
            scope: options[:scope],
            state: store_new_state!,
            nonce: store_new_nonce!,
            claims: { id_token: { amr: { essential: true } } }.to_json
          )
        end
      end
    end

    class ProconnectApiEntreprise < Proconnect
      option :name, :proconnect_api_entreprise
    end

    class ProconnectApiParticulier < Proconnect
      option :name, :proconnect_api_particulier
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  %i[entreprise particulier].each do |type|
    provider(
      "proconnect_api_#{type}",
      {
        client_id: ProConnectConfig.client_id,
        client_secret: ProConnectConfig.client_secret,
        proconnect_domain: ProConnectConfig.domain,
        redirect_uri: ProConnectConfig.redirect_uri(type),
        post_logout_redirect_uri: ProConnectConfig.host(type),
        scope: ProConnectConfig.scope
      }
    )
  end
end
