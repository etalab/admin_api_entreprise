class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :oauth_api_gouv_id, :confirmed, :created_at

  def confirmed
    object.confirmed?
  end
end
