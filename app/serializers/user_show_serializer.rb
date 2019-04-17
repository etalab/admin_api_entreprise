class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :allow_token_creation
  attribute :note, if: :admin?
  attribute :disabled_tokens, if: :admin?
  attributes :tokens
  attributes :allowed_roles

  has_many :contacts

  def tokens
    object.encoded_jwt
  end

  def disabled_tokens
    object.disabled_jwt
  end

  def admin?
    current_user.admin?
  end
end
