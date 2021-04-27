FactoryBot.define do
  factory :contact do
    sequence(:email) { |n| "contact_#{n}@example.org" }
    phone_number { '0256743256' }
    contact_type { 'other' }

    trait :with_jwt do
      jwt_api_entreprise
    end

    trait :business do
      contact_type { 'admin' }
    end

    trait :tech do
      contact_type { 'tech' }
    end

    trait :other do
      contact_type { 'other' }
    end
  end
end
