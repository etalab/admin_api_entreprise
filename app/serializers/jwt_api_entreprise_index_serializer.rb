class JwtApiEntrepriseIndexSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :iat, :exp, :blacklisted, :archived, :authorization_request_id

  attribute :subject

  def subject
    object.displayed_subject
  end

  def user_id
    object.authorization_request.try(:user_id)
  end
end
