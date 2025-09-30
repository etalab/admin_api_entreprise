class APIParticulier::OpenAPIDefinition < AbstractOpenAPIDefinition
  def open_api_definition_content
    open_api_v3_definition_content
  end

  def open_api_v3_definition_content
    open_api_remote_url_definition_content(remote_url('v3'))
  end

  def open_api_v2_definition_content
    open_api_remote_url_definition_content(remote_url('v2'))
  end

  protected

  def local_path(url)
    if url.include?('v3')
      Rails.root.join('config/api-particulier-openapi-v3.yml')
    else
      Rails.root.join('config/api-particulier-openapi.yml')
    end
  end

  def remote_url(version = nil)
    base_url + openapi_url(version)
  end

  def openapi_url(version)
    return "open-api-#{version}.yml" if version

    'open-api.yml'
  end

  def base_url
    if Rails.env.sandbox?
      'https://sandbox.particulier.api.gouv.fr/api/'
    elsif Rails.env.staging? || Rails.env.development?
      'https://staging.particulier.api.gouv.fr/api/'
    else
      'https://particulier.api.gouv.fr/api/'
    end
  end
end
