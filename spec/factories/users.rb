FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    context 'VERY_DEVELOPMENT'
    user_type 'client'
  end
end
