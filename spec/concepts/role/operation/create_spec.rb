require 'rails_helper'

RSpec.describe Role::Operation::Create do
  let(:role_params) do
    { name: 'Role test', code: 'rol1' }
  end
  let(:result) { described_class.call(params: role_params) }

  context 'when params are valid' do
    it 'creates a new role' do
      created_role = result[:model]

      expect(result).to be_success
      expect(created_role).to be_persisted
      expect(created_role.name).to eq role_params[:name]
      expect(created_role.code).to eq role_params[:code]
    end
  end

  context 'when params are invalid' do
    describe '#name' do
      let(:errors) { result['result.contract.default'].errors[:name] }

      it 'is required' do
        role_params[:name] = ''

        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'is 50 characters max' do
        role_params[:name] = 'a' * 51

        expect(result).to be_failure
        expect(errors).to include 'size cannot be greater than 50'
      end

      it 'is unique' do
        role = create :role
        role_params[:name] = role.name

        expect { result }.to_not change(Role, :count)
        expect(result).to be_failure
        expect(errors).to include 'value already exists'
      end
    end

    describe '#code' do
      let(:errors) { result['result.contract.default'].errors[:code] }

      it 'is required' do
        role_params[:code] = nil

        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      # TODO deal with this constraint to restrain jwt size
      #it 'is max 4 characters length' do
      #  role_params[:code] = '12345'

      #  expect(result).to be_failure
      #  expect(errors).to include 'size cannot be greater than 4'
      #end

      it 'is unique' do
        role = create :role
        role_params[:code] = role.code

        expect { result }.to_not change(Role, :count)
        expect(result).to be_failure
        expect(errors).to include 'value already exists'
      end
    end
  end
end
