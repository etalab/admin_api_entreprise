class APIEntreprise::OpenAPIDefinition < AbstractOpenAPIDefinition
  protected

  def local_path
    Rails.root.join('config/api-entreprise-v3-openapi.yml')
  end

  def remote_url
    if Rails.env.sandbox?
      'https://sandbox.entreprise.api.gouv.fr/v3/openapi-entreprise.yaml'
    elsif Rails.env.staging? || Rails.env.development?
      'https://staging.entreprise.api.gouv.fr/v3/openapi-entreprise.yaml'
    else
      'https://entreprise.api.gouv.fr/v3/openapi-entreprise.yaml'
    end
  end
end
