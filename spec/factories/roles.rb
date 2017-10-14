FactoryGirl.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:code, 0) { |n| "x#{n}x" }
  end
end
