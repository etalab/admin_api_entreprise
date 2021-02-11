require 'rails_helper'

describe User::Operation::Create do
  let(:user_email) { 'new@record.gg' }
  let(:user_params) do
    {
      email: user_email,
      oauth_api_gouv_id: 31442,
      context: 'very development',
      cgu_agreement_date: '2019-12-26T14:38:45.490Z'
    }
  end

  subject { described_class.call(params: user_params) }

  context 'when params are valid' do
    let(:new_user) { subject[:model] }

    it { is_expected.to be_success }

    it 'creates a new user' do
      expect { subject }.to change(User, :count).by(1)
      expect(new_user).to be_persisted
    end

    describe 'created user' do
      subject do
        result = described_class.call(params: user_params)
        result[:model]
      end

      its(:email) { is_expected.to eq(user_params[:email]) }
      its(:admin) { is_expected.to eq(false) }
      its(:tokens_newly_transfered) { is_expected.to eq(false) }
      its(:oauth_api_gouv_id) { is_expected.to eq(31442) }
      its(:context) { is_expected.to eq(user_params[:context]) }
      its(:password_digest) { is_expected.to be_blank }

      it 'sets the CGU agreement timestamp' do
        params_cgu_time = Time.zone.parse(user_params[:cgu_agreement_date])

        expect(subject.cgu_agreement_date).to eq(params_cgu_time)
      end
    end
  end

  context 'when params are invalid' do
    describe '#email' do
      let(:errors) do
        subject['result.contract.default'].errors.messages[:email]
      end

      it 'is required' do
        user_params[:email] = ''

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'has an email format' do
        user_params[:email] = 'verymail'

        expect(subject).to be_failure
        expect(errors).to include 'is in invalid format'
      end

      it 'is unique' do
        user = create(:user)
        user_params[:email] = user.email

        expect(subject).to be_failure
        expect(errors).to include 'value already exists'
      end
    end

    describe '#context' do
      let(:errors) do
        subject['result.contract.default'].errors.messages[:context]
      end

      it 'can be blank' do
        user_params[:context] = ''

        expect(subject).to be_success
        expect(errors).to be_nil
      end
    end

    describe '#oauth_api_gouv_id' do
      let(:errors) { subject['result.contract.default'].errors.messages[:oauth_api_gouv_id] }

      it 'is required' do
        user_params.delete(:oauth_api_gouv_id)

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end

      it 'is an integer' do
        user_params[:oauth_api_gouv_id] = '123'

        expect(subject).to be_failure
        expect(errors).to include('must be an integer')
      end
    end

    describe '#cgu_agreement_date' do
      let(:errors) do
        subject['result.contract.default'].errors.messages[:cgu_agreement_date]
      end

      it 'is required' do
        user_params.delete(:cgu_agreement_date)

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end

      it 'has a valid date format' do
        user_params[:cgu_agreement_date] = 'not a datetime'

        expect(subject).to be_failure
        expect(errors).to include('must be a datetime format')
      end
    end
  end
end
