require 'rails_helper'

describe JwtApiEntreprise::AdminCreate do
  let(:user) { create(:user) }
  let(:roles) { create_list(:role, 7) }
  let(:token_params) do
    {
      user_id: user.id,
      roles: roles.pluck(:code),
      subject: 'So testy'
    }
  end
  subject { described_class.call(token_params) }

  context 'when input data is valid' do
    it 'is successful' do
      expect(subject).to be_success
    end

    it 'creates the jwt' do
      expect { subject }.to change(JwtApiEntreprise, :count).by(1)
    end

    it 'belongs to the correct user' do
      created_token = subject['created_token']

      expect(created_token.user).to eq(user)
    end

    it 'is associated to the listed roles' do
      created_token = subject['created_token']

      expect(created_token.roles.to_a).to eql roles
    end
  end

  context 'when input data is invalid' do
    describe ':roles' do
      let(:errors) { subject['result.contract.params'].errors[:roles] }

      it 'is required' do
        token_params[:roles] = []

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      pending 'roles into payload must exists in database'
    end

    describe ':user_id' do
      let(:errors) { subject['result.contract.params'].errors[:user_id] }

      it 'is required' do
        token_params.delete(:user_id)

        expect(subject).to be_failure
        expect(errors).to include('is missing')
      end

      it 'is an existing user id' do
        token_params[:user_id] = 'not a user id'

        expect(subject).to be_failure
        expect(subject['errors']).to eq("user does not exist (UID : 'not a user id')")
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
