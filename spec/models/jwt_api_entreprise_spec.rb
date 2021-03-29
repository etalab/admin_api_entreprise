require 'rails_helper'

RSpec.describe JwtApiEntreprise, type: :model do
  let(:jwt) { create(:jwt_api_entreprise) }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:subject).of_type(:string) }
    it { is_expected.to have_db_column(:iat).of_type(:integer) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:exp).of_type(:integer) }
    it { is_expected.to have_db_column(:version).of_type(:string) }
    it { is_expected.to have_db_column(:blacklisted).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:archived).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:days_left_notification_sent).of_type(:json).with_options(default: []) }
    it { is_expected.to have_db_column(:authorization_request_id).of_type(:string) }
    it { is_expected.to have_db_column(:is_access_request_survey_sent).of_type(:boolean).with_options(default: false, null: false) }
  end

  describe 'db_indexes' do
    it { is_expected.to have_db_index(:created_at) }
    it { is_expected.to have_db_index(:iat) }
    it { is_expected.to have_db_index(:is_access_request_survey_sent) }
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:contacts).dependent(:delete_all) }
    it { is_expected.to have_and_belong_to_many(:roles) }
  end

  describe '.at_least_seven_days_ago_issued_tokens' do
    let!(:token) { create(:jwt_api_entreprise, iat: iat_value.to_i) }

    subject(:model) { described_class }

    context 'when the token was issued up to maximum 6 days ago' do
      let(:iat_value) { Faker::Time.backward(days: 6) }

      its(:at_least_seven_days_ago_issued_tokens) { is_expected.not_to be_exist token.id }
    end

    context 'when the token was issued since at least 7 days ago' do
      let(:iat_value) { 7.days.ago }

      its(:at_least_seven_days_ago_issued_tokens) { is_expected.to be_exist token.id }
    end
  end

  describe '.access_request_survey_not_sent_tokens' do
    let!(:token) { create(:jwt_api_entreprise, access_request_survey_sent_trait) }

    subject(:model) { described_class }

    context 'when the access request survey was not sent' do
      let(:access_request_survey_sent_trait) { :access_request_survey_not_sent }

      its(:access_request_survey_not_sent_tokens) { is_expected.to be_exist token.id }
    end

    context 'when the access request survey was sent' do
      let(:access_request_survey_sent_trait) { :access_request_survey_sent }

      its(:access_request_survey_not_sent_tokens) { is_expected.not_to be_exist token.id }
    end
  end

  describe '.satisfaction_survey_eligible_tokens' do
    subject(:model) { described_class }

    describe '.access_request_survey_not_sent_tokens' do
      it { expect(model).to receive(:access_request_survey_not_sent_tokens).and_call_original }
    end

    describe '.at_least_seven_days_ago_issued_tokens' do
      it { expect(model).to receive(:at_least_seven_days_ago_issued_tokens).and_call_original }
    end

    after { model.satisfaction_survey_eligible_tokens }
  end

  describe '#user_friendly_exp_date' do
    it 'returns a friendly formated date' do
      # About the offset here, during winter (March 17th here)
      # it is UTC+01:00 so this is a valid datetime in Paris
      datetime = DateTime.new(1998, 3, 17, 15, 28, 49, '+1')
      jwt.exp = datetime.to_i

      expect(jwt.user_friendly_exp_date).to eq('17/03/1998 à 15h28 (heure de Paris)')
    end
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

  describe '#renewal_url' do
    it 'returns the Signup\'s form URL' do
      j = create(:jwt_api_entreprise, subject: 'coucou subject', authorization_request_id: '42')
      url = Rails.configuration.jwt_renewal_url + '42'

      expect(j.renewal_url).to eq(url)
    end
  end

  # TODO XXX This is temporary, the real "subject" of a JWT is set into the
  # #temp_use_case attribute when the #subject was fill with a SIRET number
  # (legacy reasons). Fix when the #temp_use_case attirbute isn't use anymore
  describe '#displayed_subject' do
    it 'returns the #subject value if #temp_use_case is nil' do
      j = create(:jwt_api_entreprise, subject: 'coucou subject', temp_use_case: nil)

      expect(j.displayed_subject).to eq('coucou subject')
    end

    it 'returns #temp_use_case value if it is not nil' do
      j = create(:jwt_api_entreprise, subject: 'coucou subject', temp_use_case: 'coucou use case')

      expect(j.displayed_subject).to eq('coucou use case')
    end
  end

  describe '#user_and_contacts_email' do
    let(:jwt) { create(:jwt_api_entreprise, :with_contacts) }

    subject { jwt.user_and_contacts_email }

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
