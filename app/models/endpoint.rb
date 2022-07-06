# rubocop:disable Metrics/ClassLength
class Endpoint < ApplicationAlgoliaSearchableActiveModel
  attr_accessor :uid,
    :path,
    :call_id,
    :parameters,
    :providers,
    :perimeter,
    :extra_description,
    :data,
    :use_cases,
    :keywords,
    :opening

  algoliasearch_active_model do
    attributes :title, :description, :providers, :keywords

    searchableAttributes %w[
      title
      description
      providers
      keywords
    ]
  end

  def initialize(params)
    super(params)
    load_dummy_definition! if open_api_definition.blank?
  end

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

  def root_links
    @root_links ||= extract_root_properties_from_schema('links')
  end

  def root_meta
    @root_meta ||= extract_root_properties_from_schema('meta')
  end

  def example_payload
    @example_payload ||= response_schema['example'] ||
                         OpenAPISchemaToExample.new(response_schema).perform
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
      ].include?(error_payload['code'][2..])
    end
  end

  def error_examples(http_code)
    http_code_response = open_api_definition['responses'][http_code]

    return [] if http_code_response.blank?
    return [] if http_code_response['content'].blank?

    http_code_response['content']['application/json']['examples'].values.map { |example_schema_payload|
      example_schema_payload['value']['errors']
    }.flatten
  end

  def collection_types
    @collection_types ||= response_schema
      .dig('properties', 'data', 'items', 'properties', 'type') || {}
  end

  def collection?
    response_schema['properties']['data']['type'] == 'array'
  end

  def faq
    @faq || []
  end

  def faq=(faq)
    @faq = faq.map do |faq_entry|
      {
        'question' => faq_entry['q'],
        'answer' => MarkdownInterpolator.new(faq_entry['a']).perform
      }
    end
  end

  def open_api_definition
    @open_api_definition ||= OpenAPIDefinition.get(path)
  end

  def load_dummy_definition!
    @open_api_definition = I18n.t("missing_endpoints.#{path}").stringify_keys
    @dummy_definition = true
  end

  def dummy?
    @dummy_definition
  end

  def implemented?
    !dummy?
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
end
# rubocop:enable Metrics/ClassLength
