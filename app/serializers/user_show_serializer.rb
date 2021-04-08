class UserShowSerializer < ActiveModel::Serializer
  attributes :id, :email, :context, :oauth_api_gouv_id
  attribute :note, if: :admin?

  # This is to keep some kind of ascending compatibility with the dashboard
  # as discussed in the issue dashboard_api_entreprise/issues/68.
  # The all interface needs and will be reworked by frontend's gurus soon
  # and this "not really pretty" workaround will be removed then.
  has_many :contacts, serializer: ContactSerializer do
    if scope.admin?
      object.contacts
    else
      object.contacts.not_expired
    end
  end

  has_many :jwt_api_entreprise, key: 'tokens', serializer: JwtApiEntrepriseShowSerializer do
    # According to the documentation the method current_user is supposed to be
    # an alias of scope but, for unknown reasons, current_user does not exist
    # inside the block... So here scope == current_user
    if scope.admin?
      object.jwt_api_entreprise.all
    else
      object.jwt_api_entreprise.not_blacklisted.where(archived: false)
    end
  end

  def admin?
    current_user.admin?
  end
end
