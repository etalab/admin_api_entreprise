FactoryBot.define do
  factory :datapass_webhook, class: Hash do
    initialize_with { attributes.stringify_keys }

    event { %w[refuse_application refuse].sample }
    model_type { 'Pass' }
    fired_at { Time.now.to_i }
    data do
      {
        'pass' => build(:datapass_webhook_pass_model)
      }
    end

    transient do
      extra_data { {} }
      demandeur_attributes { nil }
      authorization_request_attributes { nil }
      demarche { nil }
    end

    after(:build) do |datapass_webhook, evaluator|
      datapass_webhook['data']['pass'] = build(:datapass_webhook_pass_model, evaluator.authorization_request_attributes) if evaluator.authorization_request_attributes

      datapass_webhook['data']['pass']['demarche'] = evaluator.demarche

      if evaluator.demandeur_attributes
        datapass_webhook['data']['pass']['team_members'].reject! do |team_member_model|
          team_member_model['type'] == 'demandeur'
        end

        datapass_webhook['data']['pass']['team_members'] << build(:datapass_webhook_team_member_model, evaluator.demandeur_attributes.merge(type: 'demandeur'))
      end

      datapass_webhook['data'].merge!(evaluator.extra_data)
    end
  end

  factory :datapass_webhook_pass_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id, &:to_s)
    intitule { 'intitule from webhook' }
    description { 'description from webhook' }
    demarche { nil }
    status { 'sent' }
    copied_from_enrollment_id { nil }
    siret { '13002526500013' }

    events { build_list(:datapass_webhook_event_model, 2) }

    team_members do
      [
        build(:datapass_webhook_team_member_model, type: 'demandeur'),
        build(:datapass_webhook_team_member_model, type: 'delegue_protection_donnees'),
        build(:datapass_webhook_team_member_model, type: 'responsable_traitement'),
        build(:datapass_webhook_team_member_model, type: 'responsable_technique'),
        build(:datapass_webhook_team_member_model, type: 'contact_metier')
      ]
    end

    scopes do
      {
        'associations' => true,
        'entreprises' => true
      }
    end
  end

  factory :datapass_webhook_team_member_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id, &:to_s)
    sequence(:uid) { |n| "uid#{n}" }
    type { 'demandeur' }

    after(:build) do |team_member_model|
      team_member_model['family_name'] ||= "#{team_member_model['type']} last name"
      team_member_model['given_name'] ||= "#{team_member_model['type']} first name"
      team_member_model['email'] ||= "#{team_member_model['type']}#{rand(9001)}@service.gouv.fr"
      team_member_model['job'] ||= team_member_model['type'].humanize.to_s
    end
  end

  factory :datapass_webhook_event_model, class: Hash do
    initialize_with { attributes.stringify_keys }

    sequence(:id, &:to_s)
    name { 'notify' }
    comment { 'comment' }
    created_at { rand(1..9001).seconds.ago.to_datetime.strftime('%Y-%m-%d %H:%M:%S UTC') }
    user do
      {
        'family_name' => 'Instructor last name',
        'given_name' => 'Instructor first name',
        'email' => 'instructor@service.gouv.fr'
      }
    end
  end
end
