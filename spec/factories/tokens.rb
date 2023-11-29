FactoryBot.define do
  factory :token do
    iat { Time.zone.now.to_i }
    exp { 18.months.from_now.to_i }
    version { '1.0' }
    days_left_notification_sent { [] }
    scopes { ['entreprises'] }
    extra_info { {} }

    transient do
      users { nil }
      intitule { 'Token' }
    end

    after(:build) do |token, evaluator|
      if token.authorization_request.nil?
        token.authorization_request = create(
          :authorization_request, :with_demandeur, tokens: [token], intitule: evaluator.intitule
        )
      end

      if evaluator.intitule != token.authorization_request.intitule
        token.authorization_request.intitule = evaluator.intitule
        token.authorization_request.save! if token.authorization_request.persisted?
      end
    end

    trait :with_api_particulier do
      transient do
        users { nil }
        intitule { 'Token' }
      end

      after(:build) do |token, evaluator|
        token.authorization_request = create(
          :authorization_request, :with_demandeur, tokens: [token], intitule: evaluator.intitule, api: 'particulier'
        )
        token.authorization_request.users << evaluator.users if evaluator.users
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
      blacklisted_at { nil }
    end

    trait :blacklisted do
      blacklisted_at { 1.month.ago }
    end

    trait :expired do
      exp { 20.months.ago.to_i }
    end
  end
end
