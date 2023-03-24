FactoryBot.define do
  factory :token do
    iat { Time.zone.now.to_i }
    exp { 18.months.from_now.to_i }
    archived { false }
    version { '1.0' }
    days_left_notification_sent { [] }
    scopes { [] }
    extra_info { {} }

    sequence(:authorization_request_id) { |n| "1234#{n}" }

    transient do
      user { nil }
      intitule { 'Token' }
    end

    after(:build) do |token, evaluator|
      if token.authorization_request_id && token.authorization_request.nil?
        token.authorization_request = build(
          :authorization_request, tokens: [token], intitule: evaluator.intitule
        )
      elsif token.authorization_request_id
        token.authorization_request.external_id = token.authorization_request_id
      end

      token.authorization_request.user = evaluator.user if evaluator.user
    end

    trait :with_api_particulier do
      transient do
        user { nil }
        intitule { 'Token' }
      end

      after(:build) do |token, evaluator|
        token.authorization_request = build(
          :authorization_request, tokens: [token], intitule: evaluator.intitule, api: 'particulier'
        )
        token.authorization_request.user = evaluator.user if evaluator.user
      end
    end

    trait :with_scopes do
      transient do
        scopes_count { 1 }
      end

      scopes { Array.new(scopes_count) { |i| "x#{i}x" } }
    end

    trait :with_specific_scopes do
      transient do
        specific_scopes { %w[entreprises] }
        intitule { 'Token' }
      end

      scopes { specific_scopes }
    end

    trait :access_request_survey_not_sent do
      access_request_survey_sent { false }
    end

    trait :access_request_survey_sent do
      access_request_survey_sent { true }
    end

    trait :less_than_seven_days_ago do
      created_at { 6.days.ago }
    end

    trait :seven_days_ago do
      created_at { 7.days.ago }
    end

    trait :expiring_within_3_month do
      exp { 88.days.from_now }
    end

    trait :expiring_in_1_year do
      exp { 1.year.from_now }
    end

    trait :not_blacklisted do
      blacklisted { false }
    end

    trait :blacklisted do
      blacklisted { true }

      after(:create) do |token|
        create(:contact, :business, authorization_request: token.authorization_request)
        create(:contact, :tech, authorization_request: token.authorization_request)
      end
    end

    trait :archived do
      archived { true }

      after(:create) do |token|
        create(:contact, :business, authorization_request: token.authorization_request)
        create(:contact, :tech, authorization_request: token.authorization_request)
      end
    end

    trait :not_archived do
      archived { false }

      after(:create) do |token|
        create(:contact, :business, authorization_request: token.authorization_request)
        create(:contact, :tech, authorization_request: token.authorization_request)
      end
    end

    trait :with_contacts do
      after(:create) do |token|
        create(:contact, :business, authorization_request: token.authorization_request)
        create(:contact, :business, authorization_request: token.authorization_request)
        create(:contact, :tech, authorization_request: token.authorization_request)
        create(:contact, :other, authorization_request: token.authorization_request)
      end
    end

    trait :expired do
      exp { 20.months.ago.to_i }
    end

    trait :with_magic_link do
      after(:create) do |token|
        create(:magic_link, email: token.user.email)
      end
    end
  end
end
