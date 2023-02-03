# rubocop:disable Metrics/ClassLength
class Endpoint < ApplicationAlgoliaSearchableActiveModel
  attr_accessor :uid,
    :path,
    :call_id,
    :parameters,
    :format,
    :provider_uids,
    :perimeter,
    :extra_description,
    :data,
    :use_cases,
    :use_cases_optional,
    :use_cases_forbidden,
    :keywords,
    :opening

  attr_writer :new_endpoint_uids, :old_endpoint_uids

  algoliasearch_active_model do
    attributes :title, :description, :deprecated, :provider_uids, :keywords, :use_cases, :use_cases_optional

    searchableAttributes %w[
      title
      description
      provider_uids
      keywords
      use_cases
      use_cases_optional
    ]

    attributesForFaceting %w[deprecated]
  end

  def initialize(params)
    super(params)
    load_dummy_definition! if open_api_definition.blank? || response_schema.blank? || force_dummy_load?
  end

  def self.all
    AvailableEndpoints.all.map do |endpoint|
      new(endpoint)
    end
  end

  def self.find(uid)
    available_endpoint = AvailableEndpoints.find(uid)

    raise not_found(uid) if available_endpoint.blank?

    new(available_endpoint)
  end

  def self.not_found(uid)
    ActiveRecord::RecordNotFound.new("uid '#{uid}' does not exist in AvailableEndpoints", self, :uid, uid)
  end

  def self.without_forbidden_use_case(use_case)
    all.reject { |endpoint| endpoint.use_cases_forbidden&.include?(use_case) }
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

  def deprecated
    @deprecated ||= (open_api_definition['deprecated'].nil? ? false : open_api_definition['deprecated'])
  end

  def deprecated?
    deprecated
  end

  def new_endpoints
    return [] if !deprecated? || @new_endpoint_uids.blank?

    @new_endpoint_uids.map do |new_endpoint_uid|
      Endpoint.find(new_endpoint_uid)
    end
  end

  def old_endpoints
    @old_endpoints ||= (@old_endpoint_uids || []).map do |old_endpoint_uid|
      Endpoint.find(old_endpoint_uid)
    end
  end

  def historicized?
    old_endpoints.any?
  end

  def maintenances
    open_api_definition['x-maintenances']
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
        999
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
      .dig('properties', 'data', 'items', 'properties', 'data', 'properties', 'type') || {}
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
    @open_api_definition = I18n.t("api_entreprise.missing_endpoints.#{path}").stringify_keys
    @dummy_definition = true
  end

  def dummy?
    @dummy_definition
  end

  def force_dummy_load?
    %w[
      /v3/inpi/unites_legales/{siren}/actes
    ].include?(path)
  end

  def implemented?
    !dummy?
  end

  def providers
    Provider.filter_by_uid(provider_uids)
  end

  private

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

  def response_schema
    ok_response = open_api_definition['responses']['200']

    return if ok_response.blank?

    ok_response['content']['application/json']['schema']
  end

  def tag_for_redoc
    return unless open_api_definition['tags']

    open_api_definition['tags'].first.parameterize(separator: '-').capitalize
  end

  def path_for_redoc
    path.gsub('/', '~1')
  end
end
# rubocop:enable Metrics/ClassLength
