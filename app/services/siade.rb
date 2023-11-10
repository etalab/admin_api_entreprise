class Siade
  def initialize(token:)
    @token = token
    @token_rehash = token.rehash
  end

  def entreprises(siren:)
    check_presence!(siren)

    siade_result("v3/insee/sirene/unites_legales/#{siren}")
  end

  def attestations_sociales(siren:)
    check_presence!(siren)

    siade_result("v4/urssaf/unites_legales/#{siren}/attestation_vigilance")
  end

  def attestations_fiscales(siren:)
    check_presence!(siren)

    siade_result("v4/dgfip/unites_legales/#{siren}/attestation_fiscale")
  end

  private

  def siade_result(endpoint)
    return unless endpoint && @token_rehash

    result = siade_request(endpoint)

    JSON.parse(result).try(:[], 'data')
  end

  def siade_request(endpoint)
    siade_uri = URI([domain, endpoint].join('/'))

    siade_uri.query = URI.encode_www_form(siade_params)

    RestClient.get(siade_uri.to_s, siade_headers)
  rescue RestClient::Exception => e
    raise SiadeClientError.new(e.http_code, extract_error_msg(e))
  end

  def siade_params
    { context:, recipient:, object: }
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
    @token.siret || siret_dinum
  end

  def siret_dinum
    '13002526500013'
  end

  def object
    'Admin API Entreprise request from Attestations Downloader'
  end

  def extract_error_msg(error)
    JSON.parse(error.http_body)['errors'].first['detail']
  end

  def check_presence!(siret_or_siren)
    raise SiadeClientError.new(422, 'Champ SIRET ou SIREN non rempli') if siret_or_siren.blank?
  end
end
