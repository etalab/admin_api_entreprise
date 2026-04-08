class EditorToken < ApplicationRecord
  belongs_to :editor

  validates :exp, presence: true

  scope :active, -> { where(blacklisted_at: nil).or(where('blacklisted_at > ?', Time.zone.now)).where('exp > ?', Time.zone.now.to_i) }

  def rehash
    AccessToken.create(jwt_data)
  end

  def expired?
    exp < Time.zone.now.to_i
  end

  def blacklisted?
    blacklisted_at.present? && blacklisted_at < Time.zone.now
  end

  def active?
    !blacklisted? && !expired?
  end

  private

  def jwt_data
    {
      uid: id,
      jti: id,
      sub: editor.name,
      version: '1.0',
      iat: iat,
      exp: exp,
      editor: true
    }
  end
end
