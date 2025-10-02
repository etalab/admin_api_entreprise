class APIParticulier::EndpointV2 < APIParticulier::AbstractEndpoint
  attr_accessor :extra_description

  def self.all
    v2_endpoints = endpoints_store_class.all.map do |endpoint|
      new(endpoint) if api_particulier_v2?(endpoint)
    end

    v2_endpoints.compact
  end

  def from_v2?
    true
  end

  def open_api_definition
    @open_api_definition ||= APIParticulier::OpenAPIDefinitionV2.get(path)
  end

  def extract_data_from_schema
    data_attributes_to_dig = %w[responses 200 content application/json schema properties]
    open_api_definition.dig(*data_attributes_to_dig)
  end
end
