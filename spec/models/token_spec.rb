require 'rails_helper'

RSpec.describe Token, type: :model do
  let(:token) { create(:token) }

  it 'has valid factories' do
    expect(build(:token)).to be_valid
  end

  describe '#generate_magic_link_token' do
    let(:token) { create(:token) }

    it 'generates a random string for the :magic_link_token attribute' do
      token.update(magic_link_token: nil)
      token.generate_magic_link_token
      token.reload

      expect(token.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
    end

    it 'saves the issuance date of the token' do
      creation_time = Time.zone.now
      Timecop.freeze(creation_time) do
        token.generate_magic_link_token
        token.reload

        expect(token.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
      end
    end
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
    let!(:archived) { create_list(:token, 2, :archived) }
    let!(:blacklisted) { create_list(:token, 2, :blacklisted) }
    let!(:archived_and_blacklisted) { create_list(:token, 2, :blacklisted, :archived) }

    describe '.active' do
      subject { described_class.active }

      it { is_expected.to     include(*active) }
      it { is_expected.not_to include(*archived) }
      it { is_expected.not_to include(*blacklisted) }
      it { is_expected.not_to include(*archived_and_blacklisted) }
    end

    describe '.archived' do
      subject { described_class.archived }

      it { is_expected.not_to include(*active) }
      it { is_expected.to     include(*archived) }
      it { is_expected.not_to include(*blacklisted) }
      it { is_expected.not_to include(*archived_and_blacklisted) }
    end

    describe '.blacklisted' do
      subject { described_class.blacklisted }

      it { is_expected.not_to include(*active) }
      it { is_expected.not_to include(*archived) }
      it { is_expected.to     include(*blacklisted) }
      it { is_expected.to     include(*archived_and_blacklisted) }
    end
  end

  describe '#rehash' do
    let(:jwt) { token.rehash }

    it 'returns a token' do
      expect(jwt).to match(/\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/)
    end

    describe 'generated token payload' do
      let(:payload) do
        base64_payload = jwt.split('.')[1]
        payload = Base64.urlsafe_decode64(base64_payload)
        JSON.parse(payload, symbolize_names: true)
      end

      it 'contains its owner user id into the "uid" key' do
        expect(payload.fetch(:uid)).to eq(token.user.id)
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

  describe 'external URLs to DataPass' do
    let(:external_id) { token.authorization_request.external_id }

    describe '#renewal_url' do
      it 'returns the DataPass\' renewal form URL' do
        url = Rails.configuration.token_renewal_url + external_id

        expect(token.renewal_url).to eq(url)
      end
    end

    describe '#authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        url = Rails.configuration.token_authorization_request_url + external_id

        expect(token.authorization_request_url).to eq(url)
      end
    end
  end

  describe '#user_and_contacts_email' do
    subject { token.user_and_contacts_email }

    let(:token) { create(:token, :with_contacts) }

    it 'contains the token owner\'s email (account owner)' do
      user_email = token.user.email

      expect(subject).to include(user_email)
    end

    it 'contains all token\'s contacts email' do
      contacts_emails = token.contacts.pluck(:email).uniq

      expect(subject).to include(*contacts_emails)
    end
  end

  describe '#valid' do
    it 'is invalid with scopes from different API' do
      token = build(:token)
      token.scopes << [
        create(:scope, api: :particulier),
        create(:scope, api: :entreprise)
      ]
      expect(token).not_to be_valid
    end

    it 'is valid with API Particulier scopes' do
      token = build(:token)
      token.scopes << create_list(:scope, 2, api: :particulier)
      expect(token).to be_valid
    end
  end
end
