class User < ApplicationRecord
  has_many :contacts, dependent: :destroy

  validates :email, presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/ }

  validates :user_type, presence: true,
    inclusion: { in: %w(client provider) }

  validates :context, presence: true,
    if: Proc.new { |u| u.user_type == 'client' }
end
