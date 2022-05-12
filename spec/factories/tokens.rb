FactoryBot.define do
  factory :token do
    iat { Time.zone.now.to_i }
    exp { 18.months.from_now.to_i }
    archived { false }
    version { '1.0' }
    days_left_notification_sent { [] }

    sequence(:authorization_request_id) { |n| "1234#{n}" }

    transient do
      user { nil }
      intitule { 'JWT' }
    end

    after(:build) do |token, evaluator|
      if token.authorization_request_id && token.authorization_request.nil?
        token.authorization_request = build(
          :authorization_request, token:, intitule: evaluator.intitule
        )
      elsif token.authorization_request_id
        token.authorization_request.external_id = token.authorization_request_id
      end

      token.authorization_request.user = evaluator.user if evaluator.user
    end

    trait :with_roles do
      roles do
        [
          build(:role)
        ]
      end
    end

    trait :with_specific_roles do
      transient do
        specific_roles { ['entreprises'] }
        intitule { 'JWT' }
      end

      roles do
        specific_roles.map { |role| build(:role, :with_specific_role, specific_role: role) }
      end
    end

    trait :access_request_survey_not_sent do
      access_request_survey_sent { false }
    end

    trait :access_request_survey_sent do
      access_request_survey_sent { true }
    end

    trait :less_than_seven_days_ago do
      created_at { Faker::Time.backward(days: 6) }
    end

    trait :seven_days_ago do
      created_at { 7.days.ago }
    end

    trait :expiring_within_3_month do
      exp { Faker::Time.forward(days: 88) }
    end

    trait :expiring_in_1_year do
      exp { 1.year.from_now }
    end

    trait :not_blacklisted do
      blacklisted { false }
    end

    trait :blacklisted do
      blacklisted { true }

      after(:create) do |jwt|
        create(:contact, :business, authorization_request: jwt.authorization_request)
        create(:contact, :tech, authorization_request: jwt.authorization_request)
      end
    end

    trait :archived do
      archived { true }

      after(:create) do |jwt|
        create(:contact, :business, authorization_request: jwt.authorization_request)
        create(:contact, :tech, authorization_request: jwt.authorization_request)
      end
    end

    trait :with_contacts do
      after(:create) do |jwt|
        create(:contact, :business, authorization_request: jwt.authorization_request)
        create(:contact, :business, authorization_request: jwt.authorization_request)
        create(:contact, :tech, authorization_request: jwt.authorization_request)
        create(:contact, :other, authorization_request: jwt.authorization_request)
      end
    end

    trait :expired do
      exp { Faker::Time.between(from: 20.months.ago, to: 19.months.ago).to_i }
    end

    trait :with_magic_link do
      magic_link_token { 'mUchmaGicWOW' }
      magic_link_issuance_date { Time.zone.now }
    end
  end
end
