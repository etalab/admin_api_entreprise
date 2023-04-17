class User < ApplicationRecord
  self.ignored_columns += %w[admin]

  include RandomToken

  has_many :user_authorization_request_roles, dependent: :destroy
  has_many :authorization_requests, through: :user_authorization_request_roles, dependent: :destroy

  has_many :tokens, through: :authorization_requests

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /#{EMAIL_FORMAT_REGEX}/ }

  scope :added_since_yesterday, -> { where('created_at > ?', 1.day.ago) }

  def self.find_or_initialize_by_email(email)
    insensitive_find_by_email(email) || new(email:)
  end

  def self.insensitive_find_by_email(email)
    where('email ilike (?)', email).limit(1).first
  end

  def confirmed?
    oauth_api_gouv_id.present?
  end

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  def tokens_newly_transfered?
    tokens_newly_transfered
  end

  def token
    tokens.first
  end

  def roles_for(token)
    UserAuthorizationRequestRole.where(user: self, authorization_request: token.authorization_request).pluck(:role)
  end

  def generate_pwd_renewal_token
    update(pwd_renewal_token: access_token_for(:pwd_renewal_token))
  end
end
