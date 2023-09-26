FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.org" }

  factory :user do
    email
    sequence(:oauth_api_gouv_id, &:to_s)

    trait :with_full_name do
      first_name { 'Jean-Marie' }
      last_name { 'Gigot' }
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
      created_at { 12.hours.ago }
    end

    trait :not_added_since_yesterday do
      created_at { 2.days.ago }
    end

    trait :with_token do
      transient do
        scopes { ['entreprises'] }
        tokens_amount { 1 }
      end

      after(:create) do |u, evaluator|
        evaluator.tokens_amount.times do
          create(
            :token,
            :with_specific_scopes,
            specific_scopes: evaluator.scopes,
            intitule: "Token with scopes: #{evaluator.scopes}",
            authorization_request: create(:authorization_request, :with_demandeur, demandeur: u)
          )
        end
      end
    end

    trait :with_blacklisted_token do
      after(:create) do |u|
        create(:token, :blacklisted, users: [u])
      end
    end

    trait :with_expired_token do
      after(:create) do |u|
        create(:token, :expired, users: [u])
      end
    end

    trait :with_roles do
      transient do
        roles { [] }
      end

      after(:create) do |user, evaluator|
        evaluator.roles.each do |role|
          create(
            :user_authorization_request_role,
            authorization_request: create(:authorization_request),
            user:,
            role:
          )
        end
      end
    end

    trait :demandeur do
      after(:create) do |u|
        create(
          :user_authorization_request_role,
          authorization_request: create(:authorization_request),
          user: u,
          role: 'demandeur'
        )
      end
    end

    trait :contact_technique do
      after(:create) do |u|
        create(
          :user_authorization_request_role,
          authorization_request: create(:authorization_request),
          user: u,
          role: 'contact_technique'
        )
      end
    end

    trait :contact_metier do
      after(:create) do |u|
        create(
          :user_authorization_request_role,
          authorization_request: create(:authorization_request),
          user: u,
          role: 'contact_metier'
        )
      end
    end
  end
end
