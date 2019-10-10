class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context
  attribute :note, if: :admin?
  attribute :blacklisted_tokens, if: :admin?
  attributes :tokens

  # This is to keep some kind of ascending compatibility with the dashboard
  # as discussed in the issue dashboard_api_entreprise/issues/68.
  # The all interface needs and will be reworked by frontend's gurus soon
  # and this "not really pretty" workaround will be removed then.
  has_many :contacts


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
