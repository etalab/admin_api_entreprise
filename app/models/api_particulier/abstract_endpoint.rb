class APIParticulier::AbstractEndpoint < AbstractEndpoint
  attr_accessor :call_id,
    :opening

  def description
    "#{super.split('.').first}."
  end

  def collection?
    false
  end

  def maintenances
    open_api_definition['x-maintenances']
  end

  def self.api_particulier_v2?(endpoint)
    api == 'api_particulier' && endpoint['uid'].include?('/v2/')
  end
end
