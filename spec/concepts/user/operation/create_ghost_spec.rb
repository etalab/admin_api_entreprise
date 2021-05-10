require 'rails_helper'

RSpec.describe(User::Operation::CreateGhost) do
  let(:op_params) do
    {
      email: 'new@record.com',
      context: 'actually a siret'
    }
  end

  subject { described_class.call(params: op_params) }

  describe 'validation contract' do
    let(:errors) do
      subject['result.contract.default'].errors[field]
    end

    describe '#email' do
      let(:field) { :email }

      it 'is required' do
        op_params[:email] = ''

        expect(errors).to(include('must be filled'))
      end

      it 'has an email format' do
        op_params[:email] = 'verymail'

        expect(errors).to(include('is in invalid format'))
      end
    end

    describe '#context' do
      let(:field) { :context }

      it 'is required' do
        op_params[:context] = ''

        expect(errors).to(include('must be filled'))
      end
    end
  end

  context 'when :email is valid' do
    it { is_expected.to(be_success) }

    it 'creates a user' do
      expect { subject }.to(change(User, :count).by(1))
    end

    describe 'new ghost user' do
      let(:ghost_user) { subject[:model] }

      it 'does not have an ID API Gouv' do
        expect(ghost_user.oauth_api_gouv_id).to(be_nil)
      end

      it 'is not confirmed' do
        expect(ghost_user).to_not(be_confirmed)
      end
    end
  end

  context 'when the contract fails' do
    before { op_params.delete(:email) }

    it { is_expected.to(be_failure) }

    it 'does not create a new user' do
      expect { subject }.to_not(change(User, :count))
    end
  end
end
