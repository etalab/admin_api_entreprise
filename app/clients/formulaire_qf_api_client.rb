class FormulaireQFAPIClient
  def create_collectivity(authorization_request)
    organization = authorization_request.organization
    editor_name = authorization_request.extra_infos.dig('service_provider', 'id')

    params = {
      siret: organization.siret,
      code_cog: organization.code_commune_etablissement,
      departement: organization.code_postal_etablissement[0..1],
      name: organization.denomination,
      status: 'active',
      editor: editor_name
    }

    http_connection.post("#{host}/api/collectivites", params.to_json)
  end

  private

  def host
    Rails.application.credentials.formulaire_qf.host
  end

  def http_connection(&block)
    Faraday.new do |conn|
      conn.headers['Content-Type'] = 'application/json'
      conn.request :authorization, 'Bearer', -> { secret }
      yield(conn) if block
    end
  end

  def secret
    Rails.application.credentials.formulaire_qf.secret
  end
end
