require 'rails_helper'

RSpec.describe AdminAPIToken do
  describe '.for' do
    subject(:token) { described_class.for(api) }

    let(:api) { 'api_entreprise' }

    context 'when ADMIN_API_TOKEN env var is set' do
      before { ENV['ADMIN_API_TOKEN'] = 'configured_token' }

      after { ENV.delete('ADMIN_API_TOKEN') }

      it 'returns the env var value' do
        expect(token).to eq('configured_token')
      end
    end

    context 'when in production' do
      let(:datapass_id) { '93423' }
      let(:authorization_request) { create(:authorization_request, external_id: datapass_id) }
      let(:db_token) { create(:token, authorization_request:) }

      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        db_token
      end

      it 'returns rehashed token from database' do
        expect(token).to be_a(String)
        expect(token).not_to be_empty

        decoded = AccessToken.decode(token)
        expect(decoded[:uid]).to eq(db_token.id)
      end
    end

    context 'when in non-production environment without env var' do
      before { ENV.delete('ADMIN_API_TOKEN') }

      it 'returns nil' do
        expect(token).to be_nil
      end
    end
  end
end
