class JwtApiEntrepriseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :iat, :exp, :blacklisted, :archived

  attribute :subject

  def subject
    object.displayed_subject
  end
end
