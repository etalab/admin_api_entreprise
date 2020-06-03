FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    sequence(:oauth_api_gouv_id) { |n| n }
    context { 'VERY_DEVELOPMENT' }
    cgu_agreement_date { Time.zone.now }
    sequence(:confirmation_token) { |n| "v3rytok3n#{n}" }
    confirmed_at { Time.zone.now }
    password { 'Coucou123' }

    trait :admin do
      id { Rails.application.credentials.admin_uid }
      password { Rails.application.credentials.admin_password }
    end

    trait :inactive do
      confirmed_at { nil }
      password { '' }
    end

    trait :known_api_gouv_user do
      # ID of the API Gouv User recorded in VCR's cassettes
      oauth_api_gouv_id { 5037 }
    end

    trait :with_jwt do
      after(:create) do |u|
        create_list(:jwt_api_entreprise, 2, user: u)
        create_list(:jwt_api_entreprise, 2, :with_contacts, user: u)
      end
    end

    trait :with_blacklisted_jwt do
      after(:create) do |u|
        create(:jwt_api_entreprise, :blacklisted, user: u)
      end
    end

    trait :with_archived_jwt do
      after(:create) do |u|
        create(:jwt_api_entreprise, :archived, user: u)
      end
    end
  end
end
