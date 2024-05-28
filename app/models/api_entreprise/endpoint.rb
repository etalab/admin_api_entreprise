class APIEntreprise::Endpoint < AbstractEndpoint
  attr_accessor :data,
    :extra_description,
    :format,
    :call_id,
    :parameters,
    :opening

  def initialize(params)
    super
    load_dummy_definition! if open_api_definition.blank? || response_schema.blank? || force_dummy_load?
  end

  def maintenances
    open_api_definition['x-maintenances']
  end

  def root_links
    @root_links ||= extract_root_properties_from_schema('links')
  end

  def root_meta
    @root_meta ||= extract_root_properties_from_schema('meta')
  end

  def custom_provider_errors
    @custom_provider_errors ||= error_examples('502').reject do |error_payload|
      %w[
        000
        051
        052
        053
        054
        055
        999
      ].include?(error_payload['code'][2..])
    end
  end

  def force_dummy_load?
    %w[
      /v3/inpi/unites_legales/{siren}/actes
    ].include?(path)
  end

  def load_dummy_definition!
    missing_endpoints_definition = I18n.t("api_entreprise.missing_endpoints.#{path}")
    raise 'Endpoint(s) not found, check endpoints paths are available in OpenAPI file or in missing_endpoints.yml' if missing_endpoints_definition.nil?

    @open_api_definition = missing_endpoints_definition.stringify_keys
    @dummy_definition = true
  end

  def dummy?
    @dummy_definition
  end

  def implemented?
    !dummy?
  end

  def extract_data_from_schema
    properties_path = %w[properties data properties]
    properties_path.insert(2, 'items') if collection?
    properties_path.insert(-1, 'data') if collection?
    properties_path.insert(-1, 'properties') if collection?

    response_schema.dig(*properties_path) || {}
  end

  def extract_properties_from_schema(name)
    properties_path = ['properties', 'data', 'properties', name]
    properties_path.insert(2, 'items') if collection?

    response_schema.dig(*properties_path).try(:[], 'properties') || {}
  end

  def extract_root_properties_from_schema(name)
    response_schema.dig('properties', name).try(:[], 'properties') || {}
  end
end
