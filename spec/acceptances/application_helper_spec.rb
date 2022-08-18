require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'external URLs to DataPass' do
    let(:token) { create(:token) }
    let(:external_id) { token.authorization_request.external_id }

    describe '#datapass_renewal_url' do
      it 'returns the DataPass\' renewal form URL' do
        url = Rails.configuration.token_renewal_url + external_id

        expect(datapass_renewal_url(token)).to eq(url)
      end
    end

    describe '#datapass_authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        url = Rails.configuration.token_authorization_request_url + external_id

        expect(datapass_authorization_request_url(token.authorization_request)).to eq(url)
      end
    end
  end
end
