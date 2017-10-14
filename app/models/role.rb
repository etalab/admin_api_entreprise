class Role < ApplicationRecord
  has_and_belongs_to_many :users

  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 }

  validates :code, presence: true,
                   uniqueness: true,
                   length: { maximum: 4 }
end
