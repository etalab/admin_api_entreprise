FactoryBot.define do
  factory :editor_delegation do
    editor
    authorization_request

    trait :revoked do
      revoked_at { Time.current }
    end
  end
end
