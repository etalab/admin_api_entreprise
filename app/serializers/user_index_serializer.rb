class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :confirmed, :created_at

  def confirmed
    object.confirmed?
  end
end
