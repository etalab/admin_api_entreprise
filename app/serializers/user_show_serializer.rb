class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :user_type
  attributes :tokens

  has_many :contacts

  def tokens
    object.tokens.pluck :value
  end
end
