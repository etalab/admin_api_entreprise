class APIParticulier::Endpoint < AbstractEndpoint
  def description
    super.split('.').first + '.'
  end

  def use_cases_optional
    []
  end

  def collection?
    false
  end
end
