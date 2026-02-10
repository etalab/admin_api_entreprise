class AuthorizationRequestSecuritySettings < ApplicationRecord
  belongs_to :authorization_request

  validates :rate_limit_per_minute, numericality: { greater_than: 0 }, allow_nil: true
  validate :validate_allowed_ips_format

  private

  def validate_allowed_ips_format
    return if allowed_ips.blank?

    allowed_ips.each do |ip|
      IPAddr.new(ip)
    rescue IPAddr::InvalidAddressError
      errors.add(:allowed_ips, "contains invalid IP or CIDR: #{ip}")
    end
  end
end
