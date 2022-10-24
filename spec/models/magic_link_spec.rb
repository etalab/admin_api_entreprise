require 'rails_helper'

RSpec.describe MagicLink do
  subject(:magic_link) { create(:magic_link, email:) }

  let(:email) { 'email@data.gouv.fr' }

  it 'has valid factories' do
    expect(build(:magic_link)).to be_valid
  end

  it 'generates random_token' do
    expect(magic_link.random_token).to be_a(String)
    expect(magic_link.random_token).not_to be_nil
  end

  describe 'validations' do
    describe '#email' do
      it { is_expected.to allow_value('valid@email.com').for(:email) }
      it { is_expected.not_to allow_value('not an email').for(:email) }
    end
  end

  describe 'defaults' do
    describe '#expiration_offset' do
      it 'defaults to 4 hours' do
        expect(magic_link.expiration_offset).to eq(4.hours)
      end
    end
  end

  describe '#tokens' do
    subject { described_class.new(email:).tokens(api: :particulier) }

    let(:service_instance) { instance_double(TokensAssociatedToEmailQuery) }

    before do
      allow(TokensAssociatedToEmailQuery)
        .to receive(:new)
        .with(email: magic_link.email, api: :particulier)
        .and_return(service_instance)
    end

    it 'calls appropriate service' do
      expect(service_instance).to receive(:call)

      subject
    end
  end

  describe '#expiration_time' do
    let(:magic_link) { create(:magic_link, expiration_offset: 6.hours) }

    it 'equals creation time + offset' do
      expect(magic_link.expiration_time).to be_within(10.seconds).of(DateTime.now + 6.hours)
    end
  end

  describe '#expired?' do
    let(:magic_link) { create(:magic_link, expiration_offset: 1.hour) }

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
end
