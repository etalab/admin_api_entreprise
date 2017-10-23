FactoryGirl.define do
  factory :contact do
    sequence(:email) { |n| "contact_#{n}@example.org" }
    phone_number '0256743256'
    contact_type 'other'
  end
end
