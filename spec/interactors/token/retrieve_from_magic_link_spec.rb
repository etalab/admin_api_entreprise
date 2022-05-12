require 'rails_helper'

RSpec.describe Token::RetrieveFromMagicLink do
  subject { described_class.call(params) }

  let(:params) do
    { magic_token: }
  end

  let!(:jwt) { create(:token, :with_magic_link) }
  let(:magic_token) { jwt.magic_link_token }

  context 'when the magic token is not provided' do
    before { params.delete(:magic_token) }

    it { is_expected.to be_a_failure }
  end

  context 'when the magic token does not exist' do
    let(:magic_token) { 'not a magic link token' }

    it { is_expected.to be_a_failure }
  end

  context 'when the magic token exists but is expired' do
    it 'is a failure' do
      Timecop.freeze(4.hours.from_now) do
        expect(subject).to be_a_failure
      end
    end
  end

  context 'when the magic token is valid' do
    it { is_expected.to be_a_success }

    its([:jwt]) { is_expected.to eq(jwt) }
  end
end
