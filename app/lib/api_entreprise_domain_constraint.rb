class APIEntrepriseDomainConstraint
  def matches?(request)
    request.host =~ /entreprise\.api/
  end
end
