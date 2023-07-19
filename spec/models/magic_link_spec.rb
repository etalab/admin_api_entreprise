require 'rails_helper'

RSpec.describe MagicLink do
  subject(:magic_link) { create(:magic_link, email:) }

  let(:email) { 'email@data.gouv.fr' }

  it 'has valid factories' do
    expect(build(:magic_link)).to be_valid
  end

  it 'generates access_token' do
    expect(magic_link.access_token).to be_a(String)
    expect(magic_link.access_token).not_to be_nil
  end

  describe 'validations' do
    describe '#email' do
      it { is_expected.to allow_value('valid@email.com').for(:email) }
      it { is_expected.not_to allow_value('not an email').for(:email) }
    end
  end

  describe 'defaults' do
    describe '#expires_at' do
      it 'defaults to 4 hours' do
        expect(magic_link.expires_at).to be_within(10.seconds).of(4.hours.from_now)
      end
    end
  end

  describe '#tokens' do
    context 'when Magic Link belongs to one token' do
      subject(:magic_link) { described_class.new(email:, token:).tokens }

      let(:token) { create(:token) }

      it { is_expected.to eq([token]) }
    end

    context 'when Magic Link does not belongs to one token' do
      subject { described_class.new(email:).tokens(api:) }

      let(:service_instance) { instance_double(TokensAssociatedToEmailQuery) }
      let(:api) { :particulier }

      before do
        allow(TokensAssociatedToEmailQuery)
          .to receive(:new)
          .and_return(service_instance)
      end

      it 'calls appropriate service' do
        expect(service_instance).to receive(:call)

        subject
      end
    end
  end

  describe '#expired?' do
    let(:magic_link) { create(:magic_link, expires_at: 1.hour.from_now) }

    context 'when expired' do
      before do
        magic_link
        Timecop.freeze(2.hours.from_now)
      end

      after { Timecop.return }

      its(:expired?) { is_expected.to be_truthy }
    end

    context 'when not expired' do
      its(:expired?) { is_expected.to be_falsy }
    end
  end

  describe '#initial_expiration_delay_in_hours' do
    subject { magic_link.initial_expiration_delay_in_hours }

    let(:magic_link) { create(:magic_link, created_at: 1.hour.ago, expires_at: 1.hour.from_now) }

    it { is_expected.to eq(2) }
  end

  describe 'scopes' do
    describe '.unexpired' do
      subject { described_class.unexpired }

      let!(:expired_magic_link) { create_list(:magic_link, 2, :expired) }
      let!(:unexpired_magic_link) { create_list(:magic_link, 2) }

      it 'returns unexpired magic links' do
        expect(subject).to include(*unexpired_magic_link)
      end

      it 'does not return expired magic links' do
        expect(subject).not_to include(*expired_magic_link)
      end
    end
  end
end
