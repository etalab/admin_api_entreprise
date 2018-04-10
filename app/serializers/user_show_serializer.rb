class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :allow_token_creation, :confirmed
  attributes :tokens
  attributes :allowed_roles

  has_many :contacts

  def tokens
    object.encoded_jwt
  end

  def confirmed
    object.confirmed?
  end
end
