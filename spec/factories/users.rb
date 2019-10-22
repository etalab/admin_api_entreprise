FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    context { 'VERY_DEVELOPMENT' }

    # TODO: make user factory confirmed by default
    # use an :inactive_user factory for this specific state
    factory :confirmed_user do
      confirmed_at { Time.zone.now.to_i }
      cgu_agreement_date { Time.zone.now.to_i }
    end

    factory :admin do
      id { Rails.application.secrets.fetch(:admin_uid) }
    end

    trait :with_contacts do
      after(:create) do |u|
        create(:contact, contact_type: 'tech', user: u)
        create(:contact, contact_type: 'admin', user: u)
        create(:contact, contact_type: 'other', user: u)
        create(:jwt_api_entreprise, user: u)
      end
    end

    trait :with_jwt do
      after(:create) do |u|
        create_list(:jwt_api_entreprise, 3, user: u)
      end
    end
  end
end
