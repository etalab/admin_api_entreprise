class APIParticulier::CasUsage < AbstractCasUsage
  attr_accessor :link_api_gouv

  def self.extra_attributes
    %i[link_api_gouv]
  end
end
