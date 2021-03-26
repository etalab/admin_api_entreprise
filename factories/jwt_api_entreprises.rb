FactoryBot.define do
  factory :jwt_api_entreprise do
    subject { 'Humm testy' }
    sequence(:authorization_request_id) { |n| "1234#{n}" }
    iat { Time.zone.now.to_i }
    exp { 18.months.from_now.to_i }
    blacklisted { false }
    archived { false }
    version { '1.0' }
    days_left_notification_sent { [] }
    user

    after(:create) do |jwt|
      create_list(:role, 4, jwt_api_entreprise: [jwt])
    end
  end

  factory :token_without_roles, class: JwtApiEntreprise do
    subject { 'Humm no roles' }
    user
  end

  trait :about_seven_days_ago do
    iat { 7.days.ago - 1.second }
  end

  trait :expiring_within_3_month do
    exp { Faker::Time.forward(days: 88) }
  end

  trait :expiring_in_1_year do
    exp { 1.year.from_now }
  end

  trait :blacklisted do
    blacklisted { true }

    after(:create) do |jwt|
      create(:contact, :business, jwt_api_entreprise: jwt)
      create(:contact, :tech, jwt_api_entreprise: jwt)
    end
  end

  trait :archived do
    archived { true }

    after(:create) do |jwt|
      create(:contact, :business, jwt_api_entreprise: jwt)
      create(:contact, :tech, jwt_api_entreprise: jwt)
    end
  end

  trait :with_contacts do
    after(:create) do |jwt|
      create(:contact, :business, jwt_api_entreprise: jwt)
      create(:contact, :business, jwt_api_entreprise: jwt)
      create(:contact, :tech, jwt_api_entreprise: jwt)
      create(:contact, :other, jwt_api_entreprise: jwt)
    end
  end
end
