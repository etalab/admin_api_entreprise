class APIEntreprise::OpenAPIDefinition < AbstractOpenAPIDefinition
  protected

  def local_path(_url)
    Rails.root.join('config/api-entreprise-v3-openapi.yml')
  end

  def remote_url
    "#{APIEntreprise::BASE_URL}/v3/openapi-entreprise.yaml"
  end
end
