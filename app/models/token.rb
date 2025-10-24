class Token < ApplicationRecord
  self.ignored_columns += %w[authorization_request_id]

  belongs_to :authorization_request, foreign_key: 'authorization_request_model_id', inverse_of: :tokens
  has_many :prolong_token_wizards, inverse_of: :token, dependent: :destroy
  validates :exp, presence: true

  scope :issued_in_last_seven_days, -> { where(created_at: 3.weeks.ago..1.week.ago) }
  scope :unexpired, -> { where('exp > ?', Time.zone.now.to_i) }
  scope :expired, -> { where(exp: ...Time.zone.now.to_i) }

  scope :blacklisted, -> { where(blacklisted_at: ...Time.zone.now) }
  scope :blacklisted_later, -> { where('blacklisted_at > ?', Time.zone.now) }
  scope :not_blacklisted, -> { blacklisted_later.or(where(blacklisted_at: nil)) }

  scope :active, -> { not_blacklisted.unexpired }
  scope :inactive, -> { blacklisted.or(expired) }
  scope :active_for, ->(api) { distinct.active.joins(:authorization_request).where(authorization_request: { api: }).reorder(created_at: :desc) }

  has_many :users, through: :authorization_request
  has_many :contacts, through: :authorization_request
  has_many :demandeurs, through: :authorization_request
  has_many :access_logs, inverse_of: :token, dependent: nil
  has_many :magic_links, inverse_of: :token, dependent: :destroy

  has_one :demandeur, through: :authorization_request
  delegate :contacts_no_demandeur, :archived?, to: :authorization_request

  def rehash
    AccessToken.create(jwt_data)
  end

  def access_scopes
    scopes.pluck(:code)
  end

  def expired?
    exp < Time.zone.now.to_i
  end

  def new?
    iat > 7.days.ago.to_i
  end

  def active?
    !blacklisted? && !expired?
  end

  delegate :api, to: :authorization_request

  def self.default_create_params
    {
      iat: Time.zone.now.to_i,
      version: '1.0',
      exp: 18.months.from_now.to_i,
      extra_info: {}
    }
  end

  delegate :intitule, :siret, to: :authorization_request

  def extra_info
    super || {}
  end

  def legacy_token?
    extra_info['legacy_token_id'].present?
  end

  def legacy_token_migrated?
    extra_info['legacy_token_migrated'].present?
  end

  def blacklisted?
    blacklisted_at.present? &&
      blacklisted_at < Time.zone.now
  end

  def blacklisted_later?
    blacklisted_at.present? &&
      blacklisted_at > Time.zone.now
  end

  def end_timestamp
    return blacklisted_at.to_i if blacklisted_at.present?

    exp
  end

  def create_prolong_token_wizard
    prolong_token_wizards.create!(token_id: id)
  end

  def current_prolong_token_wizard
    return create_prolong_token_wizard if last_prolong_token_wizard.nil? || last_prolong_token_wizard.renew?

    last_prolong_token_wizard
  end

  def last_prolong_token_wizard
    prolong_token_wizards.order(created_at: :desc).first
  end

  def prolong!
    update!(exp: 18.months.from_now.to_i, days_left_notification_sent: [])
  end

  private

  def jwt_data
    payload = {
      uid: id,
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
