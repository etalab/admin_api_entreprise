FactoryGirl.define do
  factory :user do
    email 'coucou@example.com'
    token 'eyJhbGciOiJIUzI1NiJ9.eyJzY29wZSI6W10sImlhdCI6MTUwNjk2OTU4Nn0.2wNOqv-CyFksb8Pe6laT0vViBcrUEOTmh4KRFCJMsz4'

    factory :user_with_roles do

      after(:create) do |user, evaluator|
        create_list(:role, 3, users: [user])
      end
    end
  end
end
