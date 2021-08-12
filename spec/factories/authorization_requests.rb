FactoryBot.define do
  sequence(:external_authorization_request_id) { |n| "#{n}" }

  factory :authorization_request do
    user

    trait :with_external_id do
      external_id { generate(:external_authorization_request_id) }
    end
  end
end
