class Siade
  API_BASE_URLS = {
    'api_entreprise' => APIEntreprise::BASE_URL,
    'api_particulier' => APIParticulier::BASE_URL
  }.freeze

  protected

  def domain(api = 'api_entreprise')
    ENV.fetch('SIADE_BASE_URL', nil) || API_BASE_URLS.fetch(api)
  end

  def build_url(endpoint)
    uri = URI([domain, endpoint].join('/'))
    uri.query = URI.encode_www_form(query_params)
    uri.to_s
  end

  def query_params
    { context:, recipient:, object: }
  end

  def headers
    { Authorization: "Bearer #{authorization_token}" }
  end

  def siret_dinum
    '13002526500013'
  end

  def request(endpoint)
    RestClient.get(build_url(endpoint), headers)
  end

  def authorization_token = raise(NotImplementedError)
  def context = raise(NotImplementedError)
  def recipient = raise(NotImplementedError)
  def object = raise(NotImplementedError)
end
