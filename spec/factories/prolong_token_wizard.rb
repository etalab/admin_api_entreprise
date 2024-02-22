FactoryBot.define do
  factory :prolong_token_wizard do
    token

    trait :prolonged do
      status { 'prolonged' }
      owner { 'still_in_charge' }
      project_purpose { true }
      contact_technique { true }
      contact_metier { true }
    end

    trait :requires_update do
      status { 'requires_update' }
      owner { 'still_in_charge' }
      project_purpose { false }
      contact_technique { false }
      contact_metier { false }
    end
  end
end
