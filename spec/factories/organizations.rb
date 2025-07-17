FactoryBot.define do
  sequence(:siret) { Faker::Company.french_siret_number }

  factory :organization do
    siret { generate(:siret) }

    trait :with_insee_payload do
      insee_payload do
        JSON.parse(Rails.root.join("spec/fixtures/insee/#{siret}.json").read)
      end
    end
  end
end
