class User < ApplicationRecord
  self.ignored_columns += %w[phone_number]

  has_many :user_authorization_request_roles, dependent: :destroy
  has_many :authorization_requests, -> { distinct.reorder(:created_at) }, through: :user_authorization_request_roles

  has_many :tokens, through: :authorization_requests

  belongs_to :editor,
    optional: true

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /#{EMAIL_FORMAT_REGEX}/ }

  before_create :sanitize_email

  scope :added_since_yesterday, -> { where('created_at > ?', 1.day.ago) }

  def self.find_or_initialize_by_email(email)
    insensitive_find_by_email(email) || new(email:)
  end

  def self.insensitive_find_by_email(email)
    return if email.blank?

    where('email ilike (?)', email.strip).limit(1).first
  end

  def self.ransackable_attributes(_)
    %w[
      email
    ]
  end

  def self.ransackable_associations(_)
    %w[
      authorization_requests
    ]
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

  def roles_for(token)
    UserAuthorizationRequestRole.where(user: self, authorization_request: token.authorization_request).pluck(:role)
  end

  def sanitize_email
    return if email.blank?

    self.email = email.downcase.strip
  end

  def editor?
    editor.present?
  end

  def admin?
    if Rails.env.production?
      Rails.application.credentials.admin_emails.include?(email)
    elsif Rails.env.development? || Rails.env.staging?
      %w[
        api-entreprise@yopmail.com
        api-particulier@yopmail.com
      ].include?(email)
    else
      email =~ /@beta.gouv.fr$/
    end
  end
end
