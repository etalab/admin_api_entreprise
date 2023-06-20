FactoryBot.define do
  factory :user_authorization_request_role do
    authorization_request
    user { association(:user, :with_full_name) }
    role { nil }

    trait :demandeur do
      role { 'demandeur' }
    end

    trait :contact_technique do
      role { 'contact_technique' }
    end

    trait :contact_metier do
      role { 'contact_metier' }
    end
  end
end
