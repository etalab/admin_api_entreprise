class OpenAPIEndpoint
  attr_reader :path, :open_api_definition, :api

  OPENAPI_SERVICES = {
    'api_entreprise' => -> { APIEntreprise::OpenAPIDefinition.instance },
    'api_particulier' => -> { APIParticulier::OpenAPIDefinition.instance }
  }.freeze

  def initialize(path:, open_api_definition:, api:)
    @path = path
    @open_api_definition = open_api_definition
    @api = api
  end

  def uid = path

  def title
    summary = open_api_definition['summary']
    return path if summary.blank?

    format_title(summary)
  end

  def transform_params(params_hash)
    params_hash
      .transform_keys { |key| array_param?(key) ? "#{key}[]" : key }
      .transform_values { |value| split_if_needed(value) }
  end

  def self.all_for_api(api)
    service = OPENAPI_SERVICES[api]&.call
    return [] unless service

    build_endpoints(service, api)
  end

  private

  def format_title(summary)
    match = summary.match(/\[(.+?)\]/)
    return summary.strip unless match

    "#{summary.gsub(/\[.*?\]/, '').strip} (#{match[1]})"
  end

  def array_param?(key)
    array_param_names.include?(key)
  end

  def array_param_names
    @array_param_names ||= openapi_parameters
      .select { |p| p['name'].end_with?('[]') }
      .map { |p| p['name'].delete_suffix('[]') }
  end

  def openapi_parameters
    open_api_definition&.dig('parameters') || []
  end

  def split_if_needed(value)
    value.is_a?(String) && value.include?(' ') ? value.split : value
  end

  class << self
    private

    def build_endpoints(service, api)
      service.backend['paths'].filter_map { |path, definition|
        next if path.include?('france_connect')

        get_def = definition['get']
        next unless get_def

        new(path:, open_api_definition: get_def, api:)
      }.sort_by(&:title)
    end
  end
end
