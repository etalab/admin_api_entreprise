class Role < ApplicationRecord
  has_and_belongs_to_many :jwt_api_entreprise
  has_and_belongs_to_many :users
end
