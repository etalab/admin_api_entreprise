class Token < ApplicationRecord
  self.ignored_columns = %w[access_request_survey_sent]

  include RandomToken

  belongs_to :authorization_request, foreign_key: 'authorization_request_model_id'
  validates :exp, presence: true
  validate :scopes_must_belong_to_only_one_api

  has_one :user, through: :authorization_request
  has_many :contacts, through: :authorization_request
  has_and_belongs_to_many :scopes

  scope :not_blacklisted, -> { where(blacklisted: false) }
  scope :issued_in_last_seven_days, -> { where(created_at: 3.weeks.ago..1.week.ago) }
  scope :unexpired, -> { where('exp > ?', Time.zone.now.to_i) }

  scope :active, -> { where(blacklisted: false, archived: false) }
  scope :archived, -> { where(blacklisted: false, archived: true) }
  scope :blacklisted, -> { where(blacklisted: true) }

  scope :valid_for, ->(api) { joins(:scopes).active.unexpired.where(scopes: { api: }).uniq }

  def rehash
    AccessToken.create(token_payload)
  end

  def access_scopes
    scopes.pluck(:code)
  end

  def expired?
    exp < Time.zone.now.to_i
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

  def api
    scopes.first.api
  end

  def self.default_create_params
    {
      iat: Time.zone.now.to_i,
      version: '1.0',
      exp: 18.months.from_now.to_i
    }
  end

  def self.find_best_token_to_retrieve_attestations(tokens)
    tokens.max_by { |token| token.decorate.attestations_scopes }
  end

  delegate :intitule, :siret, to: :authorization_request

  private

  def token_payload
    payload = {
      uid: user ? user.id : nil,
      jti: id,
      scopes: scopes.pluck(:code),
      sub: intitule,
      extra_info:,
      iat:,
      version:
    }
    # JWT is by design expired if exp is null
    payload[:exp] = exp unless exp.nil?
    payload
  end

  def scopes_must_belong_to_only_one_api
    return unless scopes.map(&:api).uniq.size > 1

    errors.add(:scopes, 'Token can only have scopes from one API')
  end
end
