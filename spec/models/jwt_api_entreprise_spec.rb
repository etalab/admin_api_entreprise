require 'rails_helper'

describe JwtApiEntreprise, type: :model do
  let(:jwt) { create(:jwt_api_entreprise) }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:subject).of_type(:string) }
    it { is_expected.to have_db_column(:iat).of_type(:integer) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:contact_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:exp).of_type(:integer) }
    it { is_expected.to have_db_column(:version).of_type(:string) }
    it { is_expected.to have_db_column(:blacklisted).of_type(:boolean).with_options(default: false) }
  end

  describe 'relationships' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:contact).optional }
    it { is_expected.to have_and_belong_to_many :roles }
  end

  describe '#rehash' do
    let(:token) { jwt.rehash }

    it 'returns a jwt' do
      expect(token).to match(/\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/)
    end

    describe 'generated JWT payload' do
      let(:payload) { extract_payload_from(token) }

      it 'contains its owner user id into the "uid" key' do
        expect(payload.fetch(:uid)).to eq(jwt.user_id)
      end

      it 'contains its id into the "jti" key' do
        expect(payload.fetch(:jti)).to eq(jwt.id)
      end

      it 'contains its subject into the "sub" key' do
        expect(payload.fetch(:sub)).to eq(jwt.subject)
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

          expect(payload).to_not have_key(:exp)
        end
      end

      it 'contains the payload version' do
        expect(payload.fetch(:version)).to_not be_nil
        expect(payload.fetch(:version)).to eq(jwt.version)
      end
    end
  end
end
