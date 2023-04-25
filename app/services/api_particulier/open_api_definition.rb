class APIParticulier::OpenAPIDefinition < AbstractOpenAPIDefinition
  protected

  def local_path
    Rails.root.join('config/api-particulier-openapi.yml')
  end

  def remote_url
    if Rails.env.sandbox?
      'https://sandbox.particulier.api.gouv.fr/api/open-api.yml'
    elsif Rails.env.staging?
      'https://staging.particulier.api.gouv.fr/api/open-api.yml'
    else
      'https://particulier.api.gouv.fr/api/open-api.yml'
    end
  end
end
