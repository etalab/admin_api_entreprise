class APIParticulier::OpenAPIDefinitionV2 < APIParticulier::OpenAPIDefinition
  def remote_url(_)
    super('v2')
  end
end
