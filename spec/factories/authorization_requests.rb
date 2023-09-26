FactoryBot.define do
  factory :authorization_request do
    intitule { 'Intitule' }
    description { 'description' }
    sequence(:external_id, &:to_s)
    status { 'draft' }
    api { 'entreprise' }
    siret { '13002526500013' }

    trait :without_external_id do
      external_id { nil }
    end

    trait :with_multiple_tokens_one_valid do
      tokens do
        [
          create(:token, :blacklisted, :expiring_in_1_year),
          create(:token, :not_blacklisted)
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

      first_submitted_at { DateTime.now }
      status { 'submitted' }
    end

    trait :validated do
      submitted

      validated_at { DateTime.now }
      status { 'validated' }
    end

    trait :with_demandeur do
      transient do
        demandeur { nil }
      end

      after(:create) do |authorization_request, evaluator|
        if evaluator.demandeur.present?
          create(:user_authorization_request_role, :demandeur, authorization_request:, user: evaluator.demandeur)
        else
          create(:user_authorization_request_role, :demandeur, authorization_request:)
        end
      end
    end

    trait :with_contact_metier do
      transient do
        contact_metier { nil }
      end

      after(:create) do |authorization_request, evaluator|
        if evaluator.contact_metier.present?
          create(:user_authorization_request_role, :contact_metier, authorization_request:, user: evaluator.demandeur)
        else
          create(:user_authorization_request_role, :contact_metier, authorization_request:)
        end
      end
    end

    trait :with_contact_technique do
      after(:create) do |authorization_request|
        create(:user_authorization_request_role, :contact_technique, authorization_request:)
      end
    end

    trait :with_all_contacts do
      with_demandeur
      with_contact_metier
      with_contact_technique
    end

    trait :with_roles do
      transient do
        roles { [] }
        user { nil }
      end

      after(:create) do |authorization_request, evaluator|
        user = evaluator.user || create(:user)

        evaluator.roles.each do |role|
          create(:user_authorization_request_role, role:, authorization_request:, user:)
        end
      end
    end
  end
end
