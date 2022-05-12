class Role < ApplicationRecord
  has_and_belongs_to_many :token

  scope :available, -> { where.not(code: Role.internal_role_codes) }

  def self.internal_role_codes
    %w[
      uptime
    ]
  end
end
