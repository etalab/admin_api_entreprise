class Scope < ApplicationRecord
  has_and_belongs_to_many :tokens
end
