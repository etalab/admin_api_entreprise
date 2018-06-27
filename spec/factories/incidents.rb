FactoryBot.define do
  factory :incident do
    sequence(:title) { |n| "Incident #{n}" }
    sequence(:subtitle) { |n| "Subtitle for incident #{n}" }
    sequence(:description) { |n| "Description for incident #{n}" }
  end
end
