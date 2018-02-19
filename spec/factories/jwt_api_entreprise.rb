FactoryBot.define do
  factory :jwt_api_entreprise do
    subject 'Humm testy'
    user

    after(:create) do |jwt|
      create_list(:role, 4, jwt_api_entreprise: [jwt])
    end
  end
end
