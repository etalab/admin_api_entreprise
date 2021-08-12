class AuthorizationRequest < ApplicationRecord
  validates :user, presence: true
end
