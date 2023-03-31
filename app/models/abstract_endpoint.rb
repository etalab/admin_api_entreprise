# rubocop:disable Metrics/ClassLength
class AbstractEndpoint < ApplicationAlgoliaSearchableActiveModel
  include AbstractAPIClass

  attr_accessor :uid,
    :path,
    :provider_uids,
    :perimeter,
    :use_cases,
    :keywords

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

  def self.all
    endpoints_store_class.all.map do |endpoint|
      new(endpoint)
    end
  end

  def self.find(uid)
    available_endpoint = endpoints_store_class.find(uid)

    raise not_found(uid) if available_endpoint.blank?

    new(available_endpoint)
  end

  def self.not_found(uid)
    ActiveRecord::RecordNotFound.new("uid '#{uid}' does not exist in #{endpoints_store_class}", self, :uid, uid)
  end

  def self.endpoints_store_class
    Kernel.const_get("#{api.classify}::EndpointsStore")
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
    @open_api_definition ||= Kernel.const_get(self.class.name.split('::')[0])::OpenAPIDefinition.get(path)
  end

  def providers
    Kernel.const_get(api.classify)::Provider.filter_by_uid(provider_uids)
  end

  def use_case?(cas_usage_name)
    use_cases&.include?(cas_usage_name)
  end

  def use_case_optionnal?(cas_usage_name)
    use_cases_optional&.include?(cas_usage_name)
  end

  def use_case_forbidden?(cas_usage_name)
    use_cases_forbidden&.include?(cas_usage_name)
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
