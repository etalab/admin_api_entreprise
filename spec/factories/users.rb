FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    context 'VERY_DEVELOPMENT'
    user_type 'client'

    factory :user_provider do
      user_type 'provider'

      after(:build) do |u|
        build(:contact, contact_type: 'tech', user: u)
        build(:contact, contact_type: 'admin', user: u)
      end
    end

    factory :user_with_contacts do
      after(:create) do |u|
        create(:contact, contact_type: 'tech', user: u)
        create(:contact, contact_type: 'admin', user: u)
        create(:contact, contact_type: 'other', user: u)
      end
    end
  end
end
