class JwtAPIEntrepriseShowSerializer < ActiveModel::Serializer
  attributes :id, :authorization_request_id, :iat, :exp, :blacklisted, :archived
  attribute :subject
  attribute :secret_key
  attribute :roles

  def subject
    object.displayed_subject
  end

  def secret_key
    object.rehash
  end

  def roles
    object.access_roles
  end
end
