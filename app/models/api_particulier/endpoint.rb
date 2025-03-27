class APIParticulier::Endpoint < AbstractEndpoint
  attr_accessor :data,
    :call_id,
    :opening

  def description
    "#{super.split('.').first}."
  end

  def maintenances
    open_api_definition['x-maintenances']
  end

  def collection?
    false
  end
end
