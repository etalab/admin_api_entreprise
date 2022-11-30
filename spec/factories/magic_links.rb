FactoryBot.define do
  factory :magic_link do
    sequence(:email) { |n| "contact_#{n}@example.org" }

    trait :expired do
      expires_at { 20.months.ago }
    end
  end
end
