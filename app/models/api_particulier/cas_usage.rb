class APIParticulier::CasUsage < AbstractCasUsage
  attr_accessor :link_api_gouv

  def self.extra_attributes
    %w[link_api_gouv]
  end
end
