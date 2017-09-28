class User < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :email, presence: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$\z/ }
end
