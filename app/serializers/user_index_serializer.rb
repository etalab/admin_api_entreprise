class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :confirmed

  def confirmed
    object.confirmed?
  end
end
