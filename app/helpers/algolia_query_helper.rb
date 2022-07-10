module AlgoliaQueryHelper
  include Rails.application.routes.url_helpers

  def endpoints_with_provider_query_filter_path(provider)
    endpoints_path + query_filter_providers(provider)
  end

  def query_filter_providers(provider)
    "?Endpoint[query]=#{provider.slug}"
  end
end
