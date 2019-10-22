require 'rails_helper'

describe JwtApiEntreprise::Operation::AdminCreate do
  let(:user) { create(:user) }
  let(:roles) { create_list(:role, 7) }
  let(:token_params) do
    {
      user_id: user.id,
      roles:   roles.pluck(:code),
      subject: 'So testy'
    }
  end
  subject { described_class.call(params: token_params) }

  context 'when input data is valid' do
    let(:created_token) { subject[:created_token] }

    it 'is successful' do
      expect(subject).to be_success
    end

    it 'creates the jwt' do
      expect { subject }.to change(JwtApiEntreprise, :count).by(1)
    end

    it 'belongs to the correct user' do
      expect(created_token.user).to eq(user)
    end

    it 'is associated to the listed roles' do
      expect(created_token.roles.to_a).to eql roles
    end

    it 'expires after 18 months' do
      expect(created_token.exp).to be_within(2).of(18.months.from_now.to_i)
    end

    it 'is saved with the payload version number' do
      expect(created_token.version).to eq('1.0')
    end

    describe 'mail notification' do
      before do
        allow(UserMailer).to receive(:token_creation_notice).and_call_original
      end

      it 'notifies contacts techniques & contact principal of token creation' do
        expect(UserMailer).to receive(:token_creation_notice)
          .with(an_instance_of(JwtApiEntreprise))
        subject
      end

      it 'does not send an email when invalid' do
        token_params.delete(:user_id)
        expect(UserMailer).to_not receive(:token_creation_notice)
        subject
      end
    end
  end

  context 'when input data is invalid' do
    describe ':roles' do
      let(:errors) { subject['result.contract.default'].errors[:roles] }

      it 'is required' do
        token_params[:roles] = []

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      pending 'roles into payload must exists in database'
    end

    describe ':user_id' do
      let(:errors) { subject['result.contract.default'].errors[:user_id] }

      it 'is required' do
        token_params.delete(:user_id)

        expect(subject).to be_failure
        expect(errors).to include('is missing')
      end

      it 'is an existing user id' do
        token_params[:user_id] = 'not a user id'

        expect(subject).to be_failure
        expect(subject[:errors]).to eq("user does not exist (UID : 'not a user id')")
      end
    end

    describe ':subject' do
      it 'can be blanck' do
        token_params[:subject] = ''

        expect(subject).to be_success
      end
    end
  end
end
