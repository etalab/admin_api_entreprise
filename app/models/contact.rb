class Contact < ApplicationRecord
  belongs_to :user

  validates :email, presence: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/ }

  validates :phone_number, format: { with: /\A0\d(\d{2}){4}$\z/ },
    allow_blank: true

  validates :contact_type, presence: true,
    inclusion: { in: %w(admin tech other) }
end
