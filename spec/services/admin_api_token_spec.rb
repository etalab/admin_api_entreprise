require 'rails_helper'

RSpec.describe AdminAPIToken do
  describe '.for' do
    subject(:token) { described_class.for('api_entreprise') }

    context 'when ADMIN_API_TOKEN env var is set' do
      before { ENV['ADMIN_API_TOKEN'] = 'configured_token' }

      after { ENV.delete('ADMIN_API_TOKEN') }

      it 'returns the env var value' do
        expect(token).to eq('configured_token')
      end
    end

    context 'when ADMIN_API_TOKEN env var is not set' do
      before { ENV.delete('ADMIN_API_TOKEN') }

      it 'returns nil' do
        expect(token).to be_nil
      end
    end
  end
end
