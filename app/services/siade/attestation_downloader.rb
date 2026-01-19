class Siade::AttestationDownloader < Siade
  def initialize(token:)
    @token = token
  end

  def entreprises(siren:)
    siade_result("v3/insee/sirene/unites_legales/#{siren}")
  end

  def attestations_sociales(siren:)
    siade_result("v4/urssaf/unites_legales/#{siren}/attestation_vigilance")
  end

  def attestations_fiscales(siren:)
    siade_result("v4/dgfip/unites_legales/#{siren}/attestation_fiscale")
  end

  private

  def siade_result(endpoint)
    JSON.parse(siade_request(endpoint)).try(:[], 'data')
  end

  def siade_request(endpoint)
    request(endpoint)
  rescue RestClient::Exception => e
    raise SiadeClientError.new(e.http_code, extract_error_msg(e))
  end

  def extract_error_msg(error)
    JSON.parse(error.http_body)['errors'].first['detail']
  end

  def authorization_token = @token.rehash
  def context = 'Admin API Entreprise'
  def recipient = @token.siret || siret_dinum
  def object = 'Admin API Entreprise request from Attestations Downloader'
end
