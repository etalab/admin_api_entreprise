class APIEntreprise::Endpoint < AbstractEndpoint
  attr_accessor :data,
    :extra_description,
    :format,
    :call_id,
    :parameters,
    :opening

  def initialize(params)
    super
    load_dummy_definition! if open_api_definition.blank? || response_schema.blank?
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
    @custom_provider_errors ||= error_examples('502').reject { |error_payload|
      %w[
        000
        051
        052
        053
        054
        055
        999
      ].include?(error_payload['code'][2..])
    }.concat(extra_provider_errors).flatten
  end

  def extra_provider_errors
    all_extra_provider_errors.map do |extra_provider_error|
      error_examples(extra_provider_error[:status]).select do |error_payload|
        error_payload['code'] == extra_provider_error[:subcode]
      end
    end
  end

  def all_extra_provider_errors
    [{ status: '404', subcode: '38422' }]
  end

  def load_dummy_definition!
    missing_endpoints_definition = I18n.t("api_entreprise.missing_endpoints.#{path}", default: nil)

    raise "Endpoint(s) #{path} not found, check endpoints paths are available in OpenAPI file or in missing_endpoints.yml" if missing_endpoints_definition.nil?

    @open_api_definition = missing_endpoints_definition.stringify_keys
    @dummy_definition = true
  rescue I18n::MissingTranslationData
    raise "There is no #{path} definition in OpenAPI file. Make sure path is valid or add the temporary data in config/locales/*/missing_endpoints.fr.yml"
  end

  def dummy?
    @dummy_definition
  end

  def implemented?
    !dummy?
  end
end
