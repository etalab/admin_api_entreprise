class APIParticulier::OpenAPIDefinition < AbstractOpenAPIDefinition
  def open_api_v3_definition_content
    open_api_remote_url_definition_content(remote_url_v3)
  end

  protected

  def local_path
    Rails.root.join('config/api-particulier-openapi.yml')
  end

  def remote_url_v3
    if Rails.env.sandbox?
      'https://sandbox.particulier.api.gouv.fr/api/open-api-v3.yml'
    elsif Rails.env.staging? || Rails.env.development?
      'https://staging.particulier.api.gouv.fr/api/open-api-v3.yml'
    else
      'https://particulier.api.gouv.fr/api/open-api-v3.yml'
    end
  end

  def remote_url
    if Rails.env.sandbox?
      'https://sandbox.particulier.api.gouv.fr/api/open-api.yml'
    elsif Rails.env.staging? || Rails.env.development?
      'https://staging.particulier.api.gouv.fr/api/open-api.yml'
    else
      'https://particulier.api.gouv.fr/api/open-api.yml'
    end
  end
end
