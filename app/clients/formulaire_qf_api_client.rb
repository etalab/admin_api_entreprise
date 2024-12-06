# :nocov:
class FormulaireQFAPIClient
  def create_collectivity(organization:, editor_id: nil)
    params = {
      siret: organization.siret,
      code_cog: organization.code_commune_etablissement,
      departement: organization.code_postal_etablissement[0..1],
      name: organization.denomination,
      status: 'active',
      editor: editor_id
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
