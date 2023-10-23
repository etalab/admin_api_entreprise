class AccessLog < ApplicationRecord
  belongs_to :token, optional: true

  def readonly?
    %w[test development].none? { |env| Rails.env == env }
  end

  scope :since, ->(timestamp) { where('timestamp > ?', timestamp) }
end
