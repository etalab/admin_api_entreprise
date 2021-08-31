FactoryBot.define do
  factory :datapass_webhook, class: Hash do
    initialize_with { attributes.stringify_keys }

    event { 'refuse_application' }
    model_type { 'Pass' }
    fired_at { Time.now.to_i }
    data do
      {
        'pass' => build(:datapass_webhook_pass_model),
      }
    end

    transient do
      user_attributes { nil }
      authorization_request_attributes { nil }
    end

    after(:build) do |datapass_webhook, evaluator|
      if evaluator.authorization_request_attributes
        datapass_webhook['data']['pass'] = build(:datapass_webhook_pass_model, evaluator.authorization_request_attributes)
      end

      if evaluator.user_attributes
        datapass_webhook['data']['pass']['user'] = build(:datapass_webhook_user_model, evaluator.user_attributes)
      end
    end
  end

  factory :datapass_webhook_pass_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id) { |n| "#{n}" }
    intitule { 'intitule from webhook' }
    description { 'description from webhook' }
    status { 'sent' }

    user { build(:datapass_webhook_user_model) }

    events { build_list(:datapass_webhook_event_model, 2) }

    contacts do
      [
        build(:datapass_webhook_contact_model, id: 'metier'),
        build(:datapass_webhook_contact_model, id: 'technique'),
      ]
    end

    scopes do
      {
        'associations' => true,
        'entreprises' => true,
        'exercices' => false,
      }
    end
  end

  factory :datapass_webhook_user_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id) { |n| "#{n}" }
    sequence(:uid) { |n| "uid#{n}" }
    given_name { 'John' }
    family_name { 'Doe' }
    sequence(:email) { |n| "john.doe.#{n}@service.api.gouv.fr" }
  end

  factory :datapass_webhook_contact_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    id { 'random' }
    phone_number { '0256743256' }

    after(:build) do |contact_model|
      contact_model['family_name'] = "#{contact_model['id']} last name"
      contact_model['given_name'] = "#{contact_model['id']} first name"
      contact_model['email'] = "#{contact_model['id']}#{rand(9001)}@service.gouv.fr"
    end
  end

  factory :datapass_webhook_event_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id) { |n| "#{n}" }
    name { 'notify' }
    comment { 'comment' }
    created_at { rand(1..9001).seconds.ago.to_datetime.strftime("%Y-%m-%d %H:%M:%S UTC") }
    user do
      {
        'family_name' => 'Instructor last name',
        'given_name' => 'Instructor first name',
        'email' => 'instructor@service.gouv.fr',
      }
    end
  end
end
