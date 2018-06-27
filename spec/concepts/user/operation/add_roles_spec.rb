require 'rails_helper'

describe User::AddRoles do
  let(:result) { described_class.call(params: op_params) }
  let(:user) { create(:user) }
  let(:roles) { create_list(:role, 3) }
  let(:op_params) do
    {
      id: user.id,
      roles: roles.pluck(:id)
    }
  end

  context 'when params are valid' do
    it 'adds the roles to a user' do
      user = User.find(result[:params][:id])

      expect(user.roles).to eq(roles)
      expect(result).to be_success
    end
  end

  context 'when params are invalid' do
    describe ':id' do
      let(:errors) { result['result.contract.default'].errors[:id] }

      it 'is required' do
        op_params.delete(:id)

        expect(result).to be_failure
        expect(errors).to include('is missing')
      end

      it 'fails if user does not exist' do
        op_params[:id] = 0

        expect(result).to be_failure
        expect(result['errors']).to eq 'user does not exist'
      end
    end

  describe ':roles' do
    it 'does not care about invalid role\'s id' do
      op_params[:roles].push('much_id')
      user = User.find(result[:params][:id])

      expect(result).to be_success
      expect(user.roles.where(id: 'much_id')).to be_empty
    end

    it 'cannot be empty' do
      op_params[:roles] = []

      expect(result).to be_failure
      expect(result['result.contract.default'].errors[:roles]).to include('must be filled')
    end
  end
  end
end
