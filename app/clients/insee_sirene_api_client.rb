class INSEESireneAPIClient < AbstractINSEEAPIClient
  class EntityNotFoundError < StandardError; end

  def etablissement(siret:)
    http_connection.get(
      "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}"
    ).body
  rescue Faraday::ResourceNotFound => e
    raise EntityNotFoundError, "Etablissement with SIRET #{siret} not found: #{e.message}"
  end

  protected

  def http_connection
    super do |conn|
      conn.request :authorization, 'Bearer', -> { INSEEAPIAuthentication.new.access_token }
    end
  end
end
