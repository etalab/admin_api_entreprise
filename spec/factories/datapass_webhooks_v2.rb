FactoryBot.define do
  sequence(:datapass_webhook_v2_id, &:to_i)

  factory :datapass_webhook_v2, class: Hash do
    initialize_with { attributes.stringify_keys }

    event { %w[refuse_application refuse].sample }
    model_id { generate(:datapass_webhook_v2_id) }
    model_type { 'authorization_request/api_entreprise' }
    fired_at { Time.zone.now.to_i }
    data factory: :datapass_webhook_data_v2
  end

  factory :datapass_webhook_data_v2, class: Hash do
    initialize_with { attributes.stringify_keys }

    state { %w[approved refused].sample }
    form_uid { 'api-entreprise' }
    applicant factory: :datapass_webhook_applicant_v2
    organization factory: :datapass_webhook_organization_v2
    data factory: :datapass_webhook_data_data_v2
  end

  factory :datapass_webhook_applicant_v2, class: Hash do
    initialize_with { attributes.stringify_keys }

    id { generate(:datapass_webhook_v2_id) }
    email { 'applicant@gouv.fr' }
    given_name { 'Nicolas' }
    family_name { 'Demandeur' }
    job_title { 'CEO' }
    phone_number { '0123456789' }
  end

  factory :datapass_webhook_organization_v2, class: Hash do
    initialize_with { attributes.stringify_keys }

    id { generate(:datapass_webhook_v2_id) }
    siret { '13002526500013' }
    raison_sociale { 'DINUM' }
  end

  factory :datapass_webhook_data_data_v2, class: Hash do
    initialize_with { attributes.stringify_keys }

    intitule { 'Intitule' }
    description { 'Description' }
    scopes { %w[association entreprises] }

    contact_technique_email { 'tech@gouv.fr' }
    contact_technique_given_name { 'Jean' }
    contact_technique_family_name { 'Tech' }
    contact_technique_job { 'CTO' }
    contact_technique_phone { '0123456789' }

    contact_metier_email { 'metier@gouv.fr' }
    contact_metier_phone_number { '0123456789' }
    contact_metier_given_name { 'Jacques' }
    contact_metier_family_name { 'Metier' }
    contact_metier_job_title { 'CMO' }
  end
end
