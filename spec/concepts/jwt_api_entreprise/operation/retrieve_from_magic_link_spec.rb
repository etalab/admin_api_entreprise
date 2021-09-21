require 'rails_helper'

RSpec.describe JwtAPIEntreprise::Operation::RetrieveFromMagicLink do
  subject { described_class.call(params: params) }

  let(:params) do
    { token: token }
  end

  let!(:jwt) { create(:jwt_api_entreprise, :with_magic_link) }
  let(:token) { jwt.magic_link_token }

  context 'when the magic token does not exist' do
    let(:token) { 'not a magic link token' }

    it { is_expected.to be_a_failure }
  end

  context 'when the magic token exists but is expired' do
    it 'is a failure' do
      Timecop.freeze(Time.zone.now + 4.hours) do
        expect(subject).to be_a_failure
      end
    end
  end

  context 'when the magic token is valid' do
    it { is_expected.to be_a_success }

    its([:jwt]) { is_expected.to eq(jwt) }
  end
end
