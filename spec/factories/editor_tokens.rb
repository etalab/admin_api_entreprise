FactoryBot.define do
  factory :editor_token do
    editor
    iat { Time.zone.now.to_i }
    exp { 18.months.from_now.to_i }

    trait :expired do
      exp { 1.month.ago.to_i }
    end

    trait :blacklisted do
      blacklisted_at { 1.month.ago }
    end
  end
end
