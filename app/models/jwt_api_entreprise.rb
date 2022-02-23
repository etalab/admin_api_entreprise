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
    return File.read('spec/fixtures/apientreprise_test_token') if Rails.env.development?

    AccessToken.create(token_payload)
  end

  def access_roles
    roles.pluck(:code)
  end

  def expired?
    exp < Time.zone.now.to_i
  end

  def renewal_url
    "#{Rails.configuration.jwt_renewal_url}#{authorization_request.external_id}"
  end

  delegate :url, to: :authorization_request, prefix: true

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
      exp: 18.months.from_now.to_i
    }
  end

  delegate :intitule, to: :authorization_request

  private

  def token_payload
    payload = {
      uid: user ? user.id : nil,
      jti: id,
      roles: roles.pluck(:code),
      sub: intitule,
      iat:,
      version:
    }
    # JWT is by design expired if exp is null
    payload[:exp] = exp unless exp.nil?
    payload
  end
end
