class User < ApplicationRecord
  devise :database_authenticatable,
    :confirmable,
    :recoverable,
    :lockable

  has_many :contacts, dependent: :destroy
  has_many :tokens, dependent: :nullify
end
