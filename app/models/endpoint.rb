class Endpoint
  include ActiveModel::Model

  attr_accessor :uid,
    :path,
    :call_id,
    :parameters,
    :providers,
    :perimeter,
    :use_cases,
    :faq,
    :opening

  def self.all
    AvailableEndpoints.all.map do |endpoint|
      new(endpoint)
    end
  end

  def self.find(uid)
    available_endpoint = AvailableEndpoints.find(uid)

    raise not_found(uid) unless available_endpoint.present?

    new(available_endpoint)
  end

  def self.not_found(uid)
    ActiveRecord::RecordNotFound.new("uid '#{uid}' does not exist in AvailableEndpoints", self, :uid, uid)
  end

  def id
    @id ||= uid.gsub('/', '_')
  end

  def title
    @title ||= open_api_definition['summary']
  end

  def description
    @description ||= open_api_definition['description']
  end

  def attributes
    @attributes ||= extract_data_from_schema
  end

  def redoc_anchor
    @redoc_anchor ||= "tag/#{tag_for_redoc}/paths/#{path_for_redoc}/get"
  end

  def links
    @links ||= extract_properties_from_schema('links')
  end

  def root_links
    @root_links ||= extract_root_properties_from_schema('links')
  end

  def meta
    @meta ||= extract_properties_from_schema('meta')
  end

  def root_meta
    @root_meta ||= extract_root_properties_from_schema('meta')
  end

  def example_payload
    @example_payload ||= response_schema['example'] ||
                         OpenAPISchemaToExample.new(response_schema).perform
  end

  def collection_types
    @collection_types ||= response_schema
      .dig('properties', 'data', 'items', 'properties', 'type') || {}
  end

  def collection?
    response_schema['properties']['data']['type'] == 'array'
  end

  private

  def extract_data_from_schema
    properties_path = %w[properties data properties]
    properties_path.insert(2, 'items') if collection?

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

  def response_schema
    open_api_definition['responses']['200']['content']['application/json']['schema']
  end

  def tag_for_redoc
    open_api_definition['tags'].first.parameterize(separator: '-').capitalize
  end

  def path_for_redoc
    path.gsub('/', '~1')
  end

  def open_api_definition
    @open_api_definition ||= OpenAPIDefinition.get(path)
  end
end
