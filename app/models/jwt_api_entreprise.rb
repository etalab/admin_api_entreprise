class JwtAPIEntreprise < ApplicationRecord
  self.ignored_columns = %w[
    user_id
    access_request_survey_sent
  ]

  include RandomToken

  belongs_to :authorization_request, foreign_key: 'authorization_request_model_id'
  validates :authorization_request, presence: true

  validates :exp, presence: true

  has_one :user, through: :authorization_request
  has_many :contacts, through: :authorization_request
  has_and_belongs_to_many :roles

  scope :not_blacklisted, -> { where(blacklisted: false) }
  scope :issued_in_last_seven_days, -> { where(created_at: 3.weeks.ago..1.week.ago) }
  scope :unexpired, -> { where('exp > ?', Time.zone.now.to_i) }

  scope :active, -> { where(blacklisted: false, archived: false) }
  scope :archived, -> { where(blacklisted: false, archived: true) }
  scope :blacklisted, -> { where(blacklisted: true) }

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    self.roles.pluck(:code)
  end

  def renewal_url
    "#{Rails.configuration.jwt_renewal_url}#{authorization_request.external_id}"
  end

  def authorization_request_url
    authorization_request.url
  end

  def user_and_contacts_email
    Set[*contacts.pluck(:email)] << user.email
  end

  def generate_magic_link_token
    token = random_token_for(:magic_link_token)
    update(
      magic_link_token: token,
      magic_link_issuance_date: Time.zone.now
    )
  end

  def self.default_create_params
    {
      iat: Time.zone.now.to_i,
      version: '1.0',
      exp: 18.months.from_now.to_i,
    }
  end

  def intitule
    authorization_request.intitule
  end

  private

  def token_payload
    payload = {
      uid: self.user ? self.user.id : nil,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.intitule,
      iat: self.iat,
      version: self.version
    }
    # JWT is by design expired if exp is null
    payload[:exp] = self.exp unless self.exp.nil?
    payload
  end
end
