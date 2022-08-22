require 'rails_helper'

RSpec.describe ExternalUrlHelper, type: :helper do
  describe 'external URLs to DataPass' do
    let(:authorization_request) { create(:authorization_request) }
    let(:external_id) { authorization_request.external_id }

    describe '#datapass_renewal_url' do
      it 'returns the DataPass\' renewal form URL' do
        url = Rails.configuration.token_renewal_url + external_id

        expect(datapass_renewal_url(authorization_request)).to eq(url)
      end
    end

    describe '#datapass_authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        url = Rails.configuration.token_authorization_request_url + external_id

        expect(datapass_authorization_request_url(authorization_request)).to eq(url)
      end
    end
  end
end
