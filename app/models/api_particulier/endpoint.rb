class APIParticulier::Endpoint < AbstractEndpoint
  def description
    "#{super.split('.').first}."
  end

  def use_cases_optional
    []
  end
  
  def maintenances
    open_api_definition['x-maintenances']
  end

  def collection?
    false
  end

  def extract_data_from_schema
    data_attributes_to_dig = %w[responses 200 content application/json schema properties]
    open_api_definition.dig(*data_attributes_to_dig)
  end
end
