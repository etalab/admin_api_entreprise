class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context
  attribute :note, if: :admin?
  attribute :blacklisted_tokens, if: :admin?
  attributes :tokens


  def tokens
    object.encoded_jwt
  end

  def blacklisted_tokens
    object.blacklisted_jwt
  end

  def admin?
    current_user.admin?
  end
end
