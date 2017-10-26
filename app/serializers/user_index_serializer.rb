class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :user_type
end
