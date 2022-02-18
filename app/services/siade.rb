class Siade
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def entreprises(siret:)
    endpoint = "v2/entreprises/#{siret}"

    siade_request(endpoint)
  end

  def attestations_sociales(siren:)
    endpoint = "v2/attestations_sociales_acoss/#{siren}"

    siade_request(endpoint)
  end

  def attestations_fiscales(siren:)
    endpoint = "v2/attestations_fiscales_dgfip/#{siren}"

    siade_request(endpoint)
  end

  private

  def siade_request(endpoint)
    return unless endpoint && token

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
    # DINUM
    '13002526500013'
  end

  def object
    'Admin API Entreprise request from Attestations Downloader'
  end
end
