$elastic = Elasticsearch::Client.new(
  host: Rails.application.credentials.elastic_server_domain,
  log: false
)
