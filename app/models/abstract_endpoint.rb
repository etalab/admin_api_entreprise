# rubocop:disable Metrics/ClassLength
class AbstractEndpoint
  include AbstractAPIClass
  include ActiveModel::Model

  attr_accessor :uid,
    :path,
    :beta,
    :alert,
    :novelty,
    :ping_url,
    :new_version,
    :provider_uids,
    :parameters,
    :perimeter,
    :parameters_details,
    :data,
    :historique,
    :keywords,
    :api_cgu

  attr_writer :new_endpoint_uids, :old_endpoint_uids

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
    @title ||= if open_api_definition.present? && open_api_definition['summary'].present?
                 open_api_definition['summary'].gsub(/\[.*?\]/, '').strip
               else
                 'Titre indisponible'
               end
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

  def incoming
    @incoming ||= open_api_definition['tags'].nil? ? false : open_api_definition['tags'].include?('Prochainement')
  end

  def incoming?
    incoming
  end

  def beta?
    beta.present? && beta
  end

  def novelty?
    novelty.present? && novelty
  end

  def from_v2?
    false
  end

  def new_version?
    new_version.present? && new_version
  end

  def api_status
    return if ping_url.blank?

    @api_status_code ||= Net::HTTP.get_response(URI(ping_url)).code

    @api_status_code == '200' ? 'up' : 'down'
  end

  def pending_status
    return 'novelty' if novelty?
    return 'beta' if beta?
    return 'new_version' if new_version?
    return 'deprecated' if deprecated?

    'incoming' if incoming?
  end

  def new_endpoints
    return [] if !deprecated? || @new_endpoint_uids.blank?

    @new_endpoint_uids.map do |new_endpoint_uid|
      self.class.find(new_endpoint_uid)
    end
  end

  def old_endpoints
    @old_endpoints ||= (@old_endpoint_uids || []).map do |old_endpoint_uid|
      self.class.find(old_endpoint_uid)
    end
  end

  def historicized?
    old_endpoints.any?
  end

  def attributes
    @attributes ||= extract_data_from_schema
  end

  def redoc_anchor
    @redoc_anchor ||= "tag/#{tag_for_redoc}/paths/#{path_for_redoc}/get"
  end

  def example_payload
    @example_payload ||= response_schema['example'] ||
                         OpenAPISchemaToExample.new(response_schema).perform
  end

  def response_schema
    ok_response = open_api_definition['responses']['200']

    return if ok_response.blank?

    ok_response['content']['application/json']['schema']
  end

  def error_examples(http_code)
    http_code_response = open_api_definition['responses'][http_code]

    return [] if http_code_response.blank?
    return [] if http_code_response['content'].blank?

    http_code_response['content']['application/json']['examples'].values.map { |example_schema_payload|
      example_schema_payload['value']['errors']
    }.flatten
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

  def use_cases
    @use_cases ||= Kernel.const_get(api.classify)::CasUsage.for_endpoint(uid)
  end

  def use_cases_optional
    @use_cases_optional ||= Kernel.const_get(api.classify)::CasUsage.optional_for_endpoint(uid)
  end

  def use_cases_forbidden
    @use_cases_forbidden ||= Kernel.const_get(api.classify)::CasUsage.forbidden_for_endpoint(uid)
  end

  def test_cases_external_url
    "https://github.com/etalab/siade_staging_data/tree/develop/payloads/#{operation_id}"
  end

  def operation_id
    open_api_definition['responses']['200']['x-operationId']
  end

  private

  def tag_for_redoc
    return unless open_api_definition['tags']

    open_api_definition['tags'].first.gsub('&', 'and').parameterize(separator: '-', preserve_case: true)
  end

  def path_for_redoc
    path.gsub('/', '~1')
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
# rubocop:enable Metrics/ClassLength
