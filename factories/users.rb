FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    sequence(:oauth_api_gouv_id) { |n| "#{n}" }
    context { 'VERY_DEVELOPMENT' }
    cgu_agreement_date { Time.zone.now }
    password { 'Coucou123' }
    tokens_newly_transfered { false }

    trait :full_name do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :admin do
      admin { true }
      password { AuthenticationHelper::ADMIN_PWD }
    end

    trait :known_api_gouv_user do
      oauth_api_gouv_id { '5037' } # Hard coded ID in VCR's cassette
      email { 'alexandre.depablo@data.gouv.fr' }
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
