class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context
  attributes :tokens

  has_many :contacts

  def tokens
    object.encoded_jwt
  end
end
