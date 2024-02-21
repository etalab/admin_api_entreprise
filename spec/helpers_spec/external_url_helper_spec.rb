require 'rails_helper'

RSpec.describe ExternalUrlHelper, type: :helper do
  describe 'external URLs to DataPass' do
    let(:prolong_token_wizard) { create(:prolong_token_wizard, token:, status: 'requires_update', owner: 'still_in_charge', project_purpose: false, contact_metier: false, contact_technique: false) }
    let(:token) { create(:token, authorization_request:) }
    let(:authorization_request) { create(:authorization_request) }
    let(:external_id) { authorization_request.external_id }

    describe '#datapass_authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        expect(datapass_authorization_request_url(authorization_request)).to include("datapass.api.gouv.fr/api-#{authorization_request.api}/#{external_id}")
      end
    end

    describe '#datapass_reopen_authorization_request_url' do
      it 'returns the DataPass\' authorization request URL with highlight sections' do
        expect(datapass_reopen_authorization_request_url(authorization_request, prolong_token_wizard)).to include("datapass.api.gouv.fr/reopen-enrollment-request/#{external_id}?highlightedSections=description,contact_metier,contact_technique")
      end
    end
  end
end
