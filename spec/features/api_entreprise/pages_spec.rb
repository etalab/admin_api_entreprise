require 'rails_helper'

RSpec.describe 'Simple pages', app: :api_entreprise do
  before do
    stub_hyperping_request_operational('entreprise')
  end

  it_behaves_like 'static pages feature',
    developers_content: 'siret',
    expected_api_name: 'API Entreprise'
end
