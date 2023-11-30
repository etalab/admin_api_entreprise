# rubocop:disable Metrics/ClassLength
class AbstractEndpoint < ApplicationAlgoliaSearchableActiveModel
  include AbstractAPIClass

  attr_accessor :uid,
    :path,
    :beta,
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
    Kernel.const_get(api.classify)::CasUsage
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

  def tag_for_redoc
    return unless open_api_definition['tags']

    open_api_definition['tags'].first.parameterize(separator: '-').capitalize
  end

  def path_for_redoc
    path.gsub('/', '~1')
  end
end
# rubocop:enable Metrics/ClassLength
