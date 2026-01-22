class OAuthApplication < ApplicationRecord
  belongs_to :owner, polymorphic: true, optional: true

  has_many :editors, dependent: :nullify
  has_many :authorization_requests, dependent: :nullify

  validates :name, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :secret, presence: true

  before_validation :generate_credentials, on: :create

  private

  def generate_credentials
    self.uid ||= SecureRandom.hex(32)
    self.secret ||= SecureRandom.hex(64)
  end
end
