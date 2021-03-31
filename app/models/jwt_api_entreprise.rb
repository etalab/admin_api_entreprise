class JwtApiEntreprise < ApplicationRecord
  belongs_to :user
  has_many :contacts, dependent: :delete_all
  has_and_belongs_to_many :roles

  scope :access_request_survey_not_sent, -> { where(access_request_survey_sent: false) }
  scope :issued_in_last_seven_days, -> { where('iat <= ?', 7.days.ago.to_i) }

  def self.mark_access_request_survey_sent!(id)
    updated_rows_count = access_request_survey_not_sent.where(id: id).update_all(access_request_survey_sent: true)
    updated_rows_count.positive?
  end

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    self.roles.pluck(:code)
  end

  def user_friendly_exp_date
    "#{Time.zone.at(exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end

  def renewal_url
    "#{Rails.configuration.jwt_renewal_url}#{authorization_request_id}"
  end

  def user_and_contacts_email
    Set[*contacts.pluck(:email)] << user.email
  end

  # TODO XXX This is temporary, the real "subject" of a JWT is set into the
  # #temp_use_case attribute when the #subject was fill with a SIRET number
  # (legacy reasons). Fix when the #temp_use_case attirbute isn't use anymore
  def displayed_subject
    temp_use_case || subject
  end

  private

  def token_payload
    payload = {
      uid: self.user_id,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.subject,
      iat: self.iat,
      version: self.version
    }
    # JWT is by design expired if exp is null
    payload[:exp] = self.exp unless self.exp.nil?
    payload
  end
end
