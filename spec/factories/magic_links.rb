FactoryBot.define do
  factory :magic_link do
    sequence(:email) { |n| "contact_#{n}@example.org" }
  end
end
