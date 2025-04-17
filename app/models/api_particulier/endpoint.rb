class APIParticulier::Endpoint < APIParticulier::AbstractEndpoint
  attr_accessor :data

  def self.all
    all_endpoints = endpoints_store_class.all.map do |endpoint|
      new(endpoint) unless api_particulier_v2?(endpoint)
    end

    all_endpoints.compact
  end
end
