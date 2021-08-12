FactoryBot.define do
  factory :contact do
    sequence(:email) { |n| "contact_#{n}@example.org" }
    phone_number { '0256743256' }
    contact_type { 'other' }
    authorization_request

    transient do
      jwt_api_entreprise { nil }
    end

    after(:build) do |contact, evaluator|
      if evaluator.jwt_api_entreprise
        contact.authorization_request = evaluator.jwt_api_entreprise.authorization_request
        contact.authorization_request.user = evaluator.jwt_api_entreprise.user
      end
    end

    trait :with_full_name do
      first_name { 'Jean-Marc' }
      last_name { 'Gigot' }
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
