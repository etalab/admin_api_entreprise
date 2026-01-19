module APIRequestsHelper
  FIXED_PARAMS = %w[recipient context object].freeze

  def endpoints_grouped_by_tag(endpoints)
    endpoints.group_by { |e| e.open_api_definition&.dig('tags')&.first || 'Autre' }
      .transform_values { |eps| eps.map { |e| [e.title, e.uid] } }
  end

  def all_params(endpoint)
    path_params_list(endpoint) + query_params_list(endpoint)
  end

  def humanize_param_name(name)
    name.underscore.humanize
  end

  private

  def path_params_list(endpoint)
    endpoint.path.scan(/\{(\w+)\}/).flatten.map do |name|
      { name:, required: true }
    end
  end

  def query_params_list(endpoint)
    openapi_params = endpoint.open_api_definition&.dig('parameters') || []
    openapi_params.filter_map do |param|
      next if param['in'] != 'query' || FIXED_PARAMS.include?(param['name'])

      { name: param['name'], required: param['required'] }
    end
  end
end
