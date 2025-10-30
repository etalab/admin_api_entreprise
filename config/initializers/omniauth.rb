OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

case Rails.env
when 'development', 'test'
  port = ENV['DOCKER'].present? ? 5000 : 3000

  host = "http://localhost:#{port}"
when 'sandbox', 'staging'
  host = "https://#{Rails.env}.datapass.api.gouv.fr"
when 'production'
  host = 'https://datapass.api.gouv.fr'
end

module OmniAuth::Strategies
  class ProconnectApiEntreprise < Proconnect
    option :name, :proconnect_api_entreprise
  end

  class ProconnectApiParticulier < Proconnect
    option :name, :proconnect_api_particulier
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  %i[entreprise particulier].each do |type|
    case Rails.env
    when 'development', 'test'
      port = ENV['DOCKER'].present? ? 5000 : 3000

      host = "http://#{type}.api.localtest.me:#{port}"
    when 'sandbox', 'staging'
      host = "https://#{Rails.env}.#{type}.api.gouv.fr"
    when 'production'
      host = "https://#{type}.api.gouv.fr"
    end

    provider(
      "proconnect_api_#{type}",
      {
        client_id: Rails.application.credentials.proconnect_client_id,
        client_secret: Rails.application.credentials.proconnect_client_secret,
        proconnect_domain: Rails.application.credentials.proconnect_url,
        redirect_uri: URI("#{host}/auth/proconnect_api_#{type}/callback").to_s,
        post_logout_redirect_uri: URI(host).to_s,
        scope: 'openid given_name usual_name email uid idp_id siret phone',
      }
    )
  end
end
