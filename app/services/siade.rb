class SiadeClientError < StandardError
  attr_reader :code

  def initialize(code, msg = 'Error with Siade client')
    @code = code

    super(msg)
  end
end

class Siade
  def initialize(token_rehash:)
    token_rehash = File.read('config/apientreprise_test_token') if Rails.env.development?

    @token_rehash = token_rehash
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
    return unless endpoint && @token_rehash

    result = siade_request(endpoint)

    JSON.parse(result)
  end

  def siade_request(endpoint)
    siade_url = [domain, endpoint, '?', siade_params].join

    RestClient.get siade_url, siade_headers
  rescue RestClient::Exception => e
    raise SiadeClientError.new(e.http_code, e.message)
  end

  def siade_params
    ["context=#{context}", "recipient=#{recipient}", "object=#{object}"].join('&')
  end

  def siade_headers
    { Authorization: "Bearer #{@token_rehash}" }
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
