FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.org" }

  factory :user do
    email
    sequence(:oauth_api_gouv_id) { |n| "#{n}" }
    context { 'VERY_DEVELOPMENT' }
    cgu_agreement_date { Time.zone.now }
    tokens_newly_transfered { false }

    trait :with_full_name do
      first_name { 'Jean-Marie' }
      last_name { 'Gigot' }
    end

    trait :with_note do
      note { 'much note' }
    end

    trait :admin do
      admin { true }
    end

    trait :known_api_gouv_user do
      oauth_api_gouv_id { '5037' } # Hard coded ID in VCR's cassette
      email { 'alexandre.depablo@data.gouv.fr' }
    end

    trait :added_since_yesterday do
      created_at { Faker::Time.between(from: 1.day.ago + 1, to: Time.current) }
    end

    trait :not_added_since_yesterday do
      created_at { Faker::Time.between(from: 10.years.ago, to: 1.day.ago) }
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

    trait :with_expired_jwt do
      after(:create) do |u|
        create(:jwt_api_entreprise, :expired, user: u)
      end
    end
  end
end
