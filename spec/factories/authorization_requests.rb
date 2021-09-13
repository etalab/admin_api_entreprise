FactoryBot.define do
  sequence(:external_authorization_request_id) { |n| "#{n}" }

  factory :authorization_request do
    user { build(:user, :with_full_name) }

    trait :with_external_id do
      external_id { generate(:external_authorization_request_id) }
    end

    trait :with_contacts do
      contacts do
        [
          build(:contact, :with_full_name, :business),
          build(:contact, :with_full_name, :tech),
        ]
      end
    end
  end
end
