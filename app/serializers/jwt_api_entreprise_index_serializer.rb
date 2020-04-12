class JwtApiEntrepriseIndexSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :iat, :exp, :blacklisted, :archived, :authorization_request_id

  attribute :subject

  def subject
    object.displayed_subject
  end
end
