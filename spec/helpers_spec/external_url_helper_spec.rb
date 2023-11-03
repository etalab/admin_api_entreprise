require 'rails_helper'

RSpec.describe ExternalUrlHelper, type: :helper do
  describe 'external URLs to DataPass' do
    let(:authorization_request) { create(:authorization_request) }
    let(:external_id) { authorization_request.external_id }

    describe '#datapass_renewal_url' do
      it 'returns the DataPass\' renewal form URL' do
        expect(datapass_renewal_url(authorization_request)).to include("datapass.api.gouv.fr/copy-authorization-request/#{external_id}")
      end
    end

    describe '#datapass_authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        expect(datapass_authorization_request_url(authorization_request)).to include("datapass.api.gouv.fr/api-#{authorization_request.api}/#{external_id}")
      end
    end
  end
end
