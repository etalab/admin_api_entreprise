FactoryBot.define do
  factory :authorization_request do
    intitule { 'Intitule' }
    description { 'description' }
    sequence(:external_id, &:to_s)
    user { build(:user, :with_full_name) }
    status { 'draft' }
    api { 'entreprise' }

    trait :without_external_id do
      external_id { nil }
    end

    trait :with_contacts do
      contacts do
        [
          build(:contact, :with_full_name, :business),
          build(:contact, :with_full_name, :tech)
        ]
      end
    end

    trait :with_multiple_tokens_one_valid do
      tokens do
        [
          create(:token, :blacklisted, :not_archived),
          create(:token, :not_blacklisted, :not_archived)
        ]
      end

      after(:create, &:reload)
    end

    trait :with_tokens do
      tokens do
        [
          build(:token)
        ]
      end
    end

    trait :submitted do
      with_tokens
      with_contacts

      first_submitted_at { DateTime.now }
      status { 'submitted' }
    end

    trait :validated do
      submitted

      validated_at { DateTime.now }
      status { 'validated' }
    end
  end
end
