class APIParticulier::Endpoint < AbstractEndpoint
  def description
    "#{super.split('.').first}."
  end

  def use_cases_optional
    []
  end

  def collection?
    false
  end

  def new_endpoints
    return [] if !deprecated? || @new_endpoint_uids.blank?

    @new_endpoint_uids.map do |new_endpoint_uid|
      self.class.find(new_endpoint_uid)
    end
  end
  
  def old_endpoints
    @old_endpoints ||= (@old_endpoint_uids || []).map do |old_endpoint_uid|
      self.class.find(old_endpoint_uid)
    end
  end

  def historicized?
    old_endpoints.any?
  end

  def extract_data_from_schema
    data_attributes_to_dig = %w[responses 200 content application/json schema properties]
    open_api_definition.dig(*data_attributes_to_dig)
  end
end
