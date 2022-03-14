class Siade
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def entreprises(siret:)
    siade_result("v2/entreprises/#{siret}")
  end

  def attestations_sociales(siren:)
    siade_result("v2/attestations_sociales_acoss/#{siren}")
  end

  def attestations_fiscales(siren:)
    siade_result("v2/attestations_fiscales_dgfip/#{siren}")
  end

  private

  def siade_result(endpoint)
    return unless endpoint && token

    result = siade_request(endpoint)

    JSON.parse(result)
  end

  def siade_request(endpoint)
    siade_url = [domain, endpoint, '?', siade_params].join

    RestClient.get siade_url
  end

  def siade_params
    ["token=#{token}", "context=#{context}", "recipient=#{recipient}", "object=#{object}"].join('&')
  end

  def domain
    Rails.application.credentials.siade_url
  end

  def context
    'Admin API Entreprise'
  end

  def recipient
    siret_dinum
  end

  def siret_dinum
    '13002526500013'
  end

  def object
    'Admin API Entreprise request from Attestations Downloader'
  end
end
