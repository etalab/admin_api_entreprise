FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.org" }

  factory :user do
    email
    sequence(:oauth_api_gouv_id, &:to_s)
    # rubocop:disable RSpec/EmptyExampleGroup
    context { 'VERY_DEVELOPMENT' }
    # rubocop:enable RSpec/EmptyExampleGroup

    cgu_agreement_date { Time.zone.now }
    tokens_newly_transfered { false }

    trait :with_full_name do
      first_name { 'Jean-Marie' }
      last_name { 'Gigot' }
    end

    trait :with_note do
      note { 'much note' }
    end

    trait :confirmed do
      sequence(:oauth_api_gouv_id) { |n| n }
    end

    trait :unconfirmed do
      sequence(:oauth_api_gouv_id) { nil }
    end

    trait :new_token_owner do
      oauth_api_gouv_id { nil }
      tokens_newly_transfered { true }
    end

    trait :added_since_yesterday do
      created_at { Faker::Time.between(from: 1.day.ago + 1, to: Time.current) }
    end

    trait :not_added_since_yesterday do
      created_at { Faker::Time.between(from: 10.years.ago, to: 1.day.ago) }
    end

    trait :with_token do
      transient do
        scopes { ['entreprises'] }
      end

      after(:create) do |u, evaluator|
        create(
          :token,
          :with_specific_scopes,
          specific_scopes: evaluator.scopes,
          user: u,
          intitule: "Token with scopes: #{evaluator.scopes}"
        )
      end
    end

    trait :with_blacklisted_token do
      after(:create) do |u|
        create(:token, :blacklisted, user: u)
      end
    end

    trait :with_archived_token do
      after(:create) do |u|
        create(:token, :archived, user: u)
      end
    end

    trait :with_expired_token do
      after(:create) do |u|
        create(:token, :expired, user: u)
      end
    end
  end
end
