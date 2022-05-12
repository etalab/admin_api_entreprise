class Scope < ApplicationRecord
  has_and_belongs_to_many :token

  scope :available, -> { where.not(code: Scope.internal_scope_codes) }

  def self.internal_scope_codes
    %w[
      uptime
    ]
  end
end
