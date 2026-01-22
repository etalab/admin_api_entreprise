FactoryBot.define do
  factory :oauth_application do
    name { 'Test OAuth Application' }

    trait :for_editor do
      owner factory: %i[editor]
    end

    trait :for_authorization_request do
      owner factory: %i[authorization_request]
    end
  end
end
