require 'rails_helper'

RSpec.describe JwtAPIEntreprise, type: :model do
  let(:jwt) { create(:jwt_api_entreprise) }

  it 'has valid factories' do
    expect(build(:jwt_api_entreprise)).to be_valid
  end

  describe '#generate_magic_link_token' do
    let(:jwt) { create(:jwt_api_entreprise) }

    it 'generates a random string for the :magic_link_token attribute' do
      jwt.update(magic_link_token: nil)
      jwt.generate_magic_link_token
      jwt.reload

      expect(jwt.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
    end

    it 'saves the issuance date of the token' do
      creation_time = Time.zone.now
      Timecop.freeze(creation_time) do
        jwt.generate_magic_link_token
        jwt.reload

        expect(jwt.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
      end
    end
  end

  describe '.issued_in_last_seven_days' do
    subject { described_class }

    let!(:token) { create(:jwt_api_entreprise, datetime_of_issue) }

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

    let!(:expired_jwt) { create_list(:jwt_api_entreprise, 2, :expired) }
    let!(:unexpired_jwt) { create_list(:jwt_api_entreprise, 2) }

    it 'returns unexpired tokens' do
      expect(subject).to include(*unexpired_jwt)
    end

    it 'does not return expired tokens' do
      expect(subject).not_to include(*expired_jwt)
    end
  end

  describe 'scopes' do
    let!(:active) { create_list(:jwt_api_entreprise, 2) }
    let!(:archived) { create_list(:jwt_api_entreprise, 2, :archived) }
    let!(:blacklisted) { create_list(:jwt_api_entreprise, 2, :blacklisted) }
    let!(:archived_and_blacklisted) { create_list(:jwt_api_entreprise, 2, :blacklisted, :archived) }

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
    let(:token) { jwt.rehash }

    it 'returns a jwt' do
      expect(token).to match(/\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/)
    end

    describe 'generated JWT payload' do
      let(:payload) do
        base64_payload = token.split('.')[1]
        payload = Base64.urlsafe_decode64(base64_payload)
        JSON.parse(payload, symbolize_names: true)
      end

      it 'contains its owner user id into the "uid" key' do
        expect(payload.fetch(:uid)).to eq(jwt.user.id)
      end

      it 'contains its id into the "jti" key' do
        expect(payload.fetch(:jti)).to eq(jwt.id)
      end

      it 'contains its authorization request intitule into the "sub" key' do
        expect(payload.fetch(:sub)).to eq(jwt.intitule)
      end

      it 'contains its creation timestamp into the "iat" key' do
        expect(payload.fetch(:iat)).to eq(jwt.iat)
      end

      it 'contains all its access roles into the "roles" key' do
        jwt_roles = jwt.roles.pluck(:code)

        expect(payload.fetch(:roles)).to eq(jwt_roles)
      end

      describe 'expiration date' do
        it 'contains its expiration date into the "exp" key when not nil' do
          expect(payload.fetch(:exp)).to eq(jwt.exp)
        end

        # ex: Watchdoge JWT for ping has no expiration date
        it 'does not set exp field when expiration date is nil' do
          jwt.exp = nil

          expect(payload).not_to have_key(:exp)
        end
      end

      it 'contains the payload version' do
        expect(payload.fetch(:version)).not_to be_nil
        expect(payload.fetch(:version)).to eq(jwt.version)
      end
    end
  end

  describe '#expired?' do
    context 'when not expired' do
      let(:token) { create(:jwt_api_entreprise, exp: 1.day.from_now) }

      it 'returns false' do
        expect(token).not_to be_expired
      end
    end

    context 'when expired' do
      let(:token) { create(:jwt_api_entreprise, exp: 1.day.ago) }

      it 'returns true' do
        expect(token).to be_expired
      end
    end
  end

  describe 'external URLs to DataPass' do
    let(:external_id) { jwt.authorization_request.external_id }

    describe '#renewal_url' do
      it 'returns the DataPass\' renewal form URL' do
        url = Rails.configuration.jwt_renewal_url + external_id

        expect(jwt.renewal_url).to eq(url)
      end
    end

    describe '#authorization_request_url' do
      it 'returns the DataPass\' authorization request URL' do
        url = Rails.configuration.jwt_authorization_request_url + external_id

        expect(jwt.authorization_request_url).to eq(url)
      end
    end
  end

  describe '#user_and_contacts_email' do
    subject { jwt.user_and_contacts_email }

    let(:jwt) { create(:jwt_api_entreprise, :with_contacts) }

    it 'contains the jwt owner\'s email (account owner)' do
      user_email = jwt.user.email

      expect(subject).to include(user_email)
    end

    it 'contains all jwt\'s contacts email' do
      contacts_emails = jwt.contacts.pluck(:email).uniq

      expect(subject).to include(*contacts_emails)
    end
  end
end
