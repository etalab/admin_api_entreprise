FactoryBot.define do
  factory :contact do
    sequence(:email) { |n| "contact_#{n}@example.org" }
    phone_number { '0256743256' }
    contact_type { 'other' }
    user

    factory :admin_contact do
      contact_type { 'admin' }
    end

    factory :tech_contact do
      contact_type { 'tech' }
    end
  end
end
