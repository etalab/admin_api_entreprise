class Siade::ManualRequest < Siade
  def initialize(endpoint_path:, params:, api: 'api_entreprise')
    @endpoint_path = endpoint_path
    @params = params
    @api = api
    @path_param_names = endpoint_path.scan(/\{(\w+)\}/).flatten.map(&:to_s)
  end

  def call
    response = request(substitute_path_params)
    { body: response.body, status: response.code }
  rescue RestClient::Exception => e
    { body: e.response.body, status: e.response.code }
  end

  private

  def substitute_path_params
    result = @endpoint_path.delete_prefix('/')
    @params.each { |key, value| result.gsub!("{#{key}}", Array(value).join(' ')) }
    result
  end

  def query_params
    user_query_params = @params.reject do |key, _|
      @path_param_names.include?(key.to_s) || fixed_query_param?(key)
    end
    super.merge(user_query_params)
  end

  def domain = super(@api)

  def authorization_token = AdminAPIToken.for(@api)
  def context = fetch_param('context') || 'Admin'
  def recipient = siret_dinum
  def object = fetch_param('object') || 'Debug requête'

  def fixed_query_param?(key)
    %w[recipient context object].include?(key.to_s)
  end

  def fetch_param(name)
    @params[name].presence || @params[name.to_sym].presence
  end
end
