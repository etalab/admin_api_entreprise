require 'rails_helper'

RSpec.describe APIEntreprise::Provider do
  it_behaves_like 'a provider model',
    provider_uid: 'infogreffe',
    routes_test: true,
    expected_routes: [
      '/v3/infogreffe/rcs/unites_legales/{siren}/extrait_kbis',
      '/v3/infogreffe/rcs/unites_legales/{siren}/mandataires_sociaux'
    ]
end
