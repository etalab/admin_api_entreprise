class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :user_type

  has_many :contacts
end
