class Token < ApplicationRecord
  self.ignored_columns += %w[access_request_survey_sent]

  include RandomToken

  belongs_to :authorization_request, foreign_key: 'authorization_request_model_id', inverse_of: :tokens
  validates :exp, presence: true

  has_one :user, through: :authorization_request
  has_many :contacts, through: :authorization_request
  has_and_belongs_to_many :old_scopes, class_name: 'Scope', join_table: 'scopes_tokens'

  scope :issued_in_last_seven_days, -> { where(created_at: 3.weeks.ago..1.week.ago) }
  scope :unexpired, -> { where('exp > ?', Time.zone.now.to_i) }

  scope :blacklisted, -> { where(blacklisted: true) }
  scope :not_blacklisted, -> { where(blacklisted: false) }

  scope :archived, -> { where(blacklisted: false, archived: true) }
  scope :not_archived, -> { where(archived: false) }

  scope :active, -> { not_blacklisted.not_archived.unexpired }
  scope :active_for, ->(api) { active.joins(:authorization_request).where(authorization_request: { api: }).uniq }

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

  delegate :api, to: :authorization_request

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
      uid: user&.id,
      jti: id,
      scopes:,
      sub: intitule,
      extra_info:,
      iat:,
      version:
    }
    # JWT is by design expired if exp is null
    payload[:exp] = exp unless exp.nil?
    payload
  end
end
