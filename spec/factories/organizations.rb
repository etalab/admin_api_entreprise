FactoryBot.define do
  sequence(:siret) { Faker::Company.french_siret_number }

  factory :organization do
    siret { generate(:siret) }
  end
end
