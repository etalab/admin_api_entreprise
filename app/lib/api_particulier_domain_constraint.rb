class APIParticulierDomainConstraint
  def matches?(request)
    request.host =~ /particulier\.api/
  end
end
