class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context
  attributes :tokens

  has_many :contacts

  def tokens
    object.tokens.pluck :value
  end
end
