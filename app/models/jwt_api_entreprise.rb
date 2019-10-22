class JwtApiEntreprise < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :roles

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    roles.pluck(:code)
  end

  def user_friendly_exp_date
    "#{Time.zone.at(exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end

  private

  def token_payload
    payload = {
      uid:     user_id,
      jti:     id,
      roles:   roles.pluck(:code),
      sub:     subject,
      iat:     iat,
      version: version
    }
    # JWT is by design expired if exp is null
    payload[:exp] = exp unless exp.nil?
    payload
  end
end
