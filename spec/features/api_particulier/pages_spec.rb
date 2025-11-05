require 'rails_helper'

RSpec.describe 'Simple pages', app: :api_particulier do
  before do
    stub_hyperping_request_operational('particulier')
  end

  it_behaves_like 'static pages feature',
    check_root_content: true,
    check_newsletter_content: true,
    check_account_page: true,
    developers_content: 'Quotient familial',
    expected_api_name: 'API Particulier',
    unexpected_api_name: 'API Entreprise'
end
