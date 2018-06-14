FactoryBot.define do
  factory :jwt_api_entreprise do
    subject 'Humm testy'
    iat Time.now.to_i
    exp 18.months.from_now.to_i
    version '1.0'
    user

    after(:create) do |jwt|
      create_list(:role, 4, jwt_api_entreprise: [jwt])
    end
  end

  factory :token_without_roles, class: JwtApiEntreprise do
    subject 'Humm no roles'
    user
  end
end
