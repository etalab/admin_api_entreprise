module AlgoliaQueryHelper
  def query_filter_providers(slug)
    "?Endpoint[query]=#{slug}"
  end
end
