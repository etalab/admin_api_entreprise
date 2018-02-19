FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    context 'VERY_DEVELOPMENT'

    factory :user_with_contacts do
      after(:create) do |u|
        create(:contact, contact_type: 'tech', user: u)
        create(:contact, contact_type: 'admin', user: u)
        create(:contact, contact_type: 'other', user: u)
        create(:jwt_api_entreprise, user: u)
      end
    end

    factory :user_with_jwt do
      after(:create) do |u|
        create_list(:jwt_api_entreprise, 3, user: u)
      end
    end
  end
end
