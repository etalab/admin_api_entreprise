FactoryGirl.define do
  factory :user do
    email "coucou@example.com"

    factory :user_with_roles do

      after(:create) do |user, evaluator|
        create(:role, name: 'Role 1', users: [user])
        create(:role, name: 'Role 2', users: [user])
        create(:role, name: 'Role 3', users: [user])
      end
    end
  end
end
