class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context
  attributes :tokens
  attributes :allowed_roles

  has_many :contacts

  def tokens
    object.encoded_jwt
  end
end
