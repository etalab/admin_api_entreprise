require 'rails_helper'

RSpec.describe Token do
  let(:token) { create(:token) }

  it 'has valid factories' do
    expect(build(:token)).to be_valid
  end

  describe '.active_for scope' do
    subject { described_class.active_for('entreprise') }

    let!(:entreprise_token) { create_list(:token, 1, :with_scopes, scopes_count: 3) }

    let(:authorization_request_particulier) do
      create(
        :authorization_request,
        api: 'particulier',
        tokens: create_list(:token, 1, :with_scopes, scopes_count: 2)
      )
    end

    let(:authorization_request_entreprise) do
      create(
        :authorization_request,
        api: 'entreprise',
        tokens: entreprise_token
      )
    end

    it 'fetches only entreprise tokens' do
      expect(subject.count).to eq(1)
      expect(subject.first.scopes.count).to eq(3)
    end
  end

  describe '#api' do
    subject { token.api }

    let(:token) { create(:token, :with_scopes) }

    it { is_expected.to eq('entreprise') }
  end

  describe '.issued_in_last_seven_days' do
    subject { described_class }

    let!(:token) { create(:token, datetime_of_issue) }

    context 'when the token was issued up to maximum 6 days ago' do
      let(:datetime_of_issue) { :less_than_seven_days_ago }

      its(:issued_in_last_seven_days) { is_expected.not_to be_exist token.id }
    end

    context 'when the token was issued since at least 7 days ago' do
      let(:datetime_of_issue) { :seven_days_ago }

      its(:issued_in_last_seven_days) { is_expected.to be_exist token.id }
    end
  end

  describe '.unexpired' do
    subject { described_class.unexpired }

    let!(:expired_token) { create_list(:token, 2, :expired) }
    let!(:unexpired_token) { create_list(:token, 2) }

    it 'returns unexpired tokens' do
      expect(subject).to include(*unexpired_token)
    end

    it 'does not return expired tokens' do
      expect(subject).not_to include(*expired_token)
    end
  end

  describe 'scopes' do
    let!(:active) { create_list(:token, 2) }
    let!(:blacklisted) { create_list(:token, 2, :blacklisted) }
    let!(:expired) { create_list(:token, 2, :expired) }

    describe '.active' do
      subject { described_class.active }

      it { is_expected.to     include(*active) }
      it { is_expected.not_to include(*blacklisted) }
      it { is_expected.not_to include(*expired) }
    end

    describe '.blacklisted' do
      subject { described_class.blacklisted }

      it { is_expected.not_to include(*active) }
      it { is_expected.to     include(*blacklisted) }
    end
  end

  describe '#rehash' do
    subject(:jwt) { token.rehash }

    it { is_expected.to match(/\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/) }

    describe 'generated token payload' do
      let(:payload) do
        base64_payload = jwt.split('.')[1]
        payload = Base64.urlsafe_decode64(base64_payload)
        JSON.parse(payload, symbolize_names: true)
      end

      it 'contains its owner user id into the "uid" key' do
        expect(payload.fetch(:uid)).to eq(token.demandeur.id)
      end

      it 'contains its id into the "jti" key' do
        expect(payload.fetch(:jti)).to eq(token.id)
      end

      it 'contains its authorization request intitule into the "sub" key' do
        expect(payload.fetch(:sub)).to eq(token.intitule)
      end

      it 'contains its creation timestamp into the "iat" key' do
        expect(payload.fetch(:iat)).to eq(token.iat)
      end

      it 'contains all its access scopes into the "scopes" key' do
        token_scopes = token.scopes.pluck(:code)

        expect(payload.fetch(:scopes)).to eq(token_scopes)
      end

      describe 'expiration date' do
        it 'contains its expiration date into the "exp" key when not nil' do
          expect(payload.fetch(:exp)).to eq(token.exp)
        end

        # ex: Watchdoge token for ping has no expiration date
        it 'does not set exp field when expiration date is nil' do
          token.exp = nil

          expect(payload).not_to have_key(:exp)
        end
      end

      it 'contains the payload version' do
        expect(payload.fetch(:version)).not_to be_nil
        expect(payload.fetch(:version)).to eq(token.version)
      end

      describe 'extra_info' do
        it 'include empty hash when extra_info is empty' do
          expect(payload[:extra_info]).to be_a(Hash)
          expect(payload[:extra_info]).to be_a_empty
        end

        context 'when the token has extra_info' do
          let(:jwt) { create(:token, extra_info: { dummy_key: 'dummy value' }).rehash }

          it 'include API Particulier UUID in extra_info' do
            expect(payload.dig(:extra_info, :dummy_key)).to eq('dummy value')
          end
        end
      end
    end
  end

  describe '#expired?' do
    context 'when not expired' do
      let(:token) { create(:token, exp: 1.day.from_now) }

      it 'returns false' do
        expect(token).not_to be_expired
      end
    end

    context 'when expired' do
      let(:token) { create(:token, exp: 1.day.ago) }

      it 'returns true' do
        expect(token).to be_expired
      end
    end
  end
end
