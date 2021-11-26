class User < ApplicationRecord
  include RandomToken

  has_many :authorization_requests, dependent: :nullify
  has_many :jwt_api_entreprise, through: :authorization_requests
  has_many :contacts, through: :authorization_requests
  has_many :roles, through: :jwt_api_entreprise

  validates :email, uniqueness: { case_sensitive: false }

  scope :added_since_yesterday, -> { where('created_at > ?', 1.day.ago) }

  def self.find_or_initialize_by_email(email)
    insensitive_find_by_email(email) || new(email: email)
  end

  def self.insensitive_find_by_email(email)
    where('email ilike (?)', email).limit(1).first
  end

  def confirmed?
    !!oauth_api_gouv_id
  end

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  def tokens_newly_transfered?
    tokens_newly_transfered
  end

  def generate_pwd_renewal_token
    update(pwd_renewal_token: random_token_for(:pwd_renewal_token))
  end
end
