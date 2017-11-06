require 'rails_helper'

describe RoleForm do
  let(:role_params) { attributes_for :role }
  let(:role_form) { described_class.new Role.new }

  context 'when params are valid' do
    it 'is valid' do
      role_form.validate role_params
      expect(role_form.errors).to be_empty
    end
  end

  describe '#name' do
    it 'is required' do
      role_params[:name] = nil
      role_form.validate role_params
      expect(role_form.errors[:name]).to include 'must be filled'
    end

    it 'is a string' do
      role_params[:name] = 1234
      role_form.validate role_params
      expect(role_form.errors[:name]).to include 'must be a string'
    end

    it 'is 50 characters max' do
      role_params[:name] = "a" * 51
      role_form.validate role_params
      expect(role_form.errors[:name]).to include 'size cannot be greater than 50'
    end

    it 'is unique'
  end

  describe '#code' do
    it 'is required' do
      role_params[:code] = ''
      role_form.validate role_params
      expect(role_form.errors[:code]).to include 'must be filled'
    end

    it 'is a string' do
      role_params[:code] = [1,2]
      role_form.validate role_params
      expect(role_form.errors[:code]).to include 'must be a string'
    end

    it 'is max 4 characters long' do
      role_params[:code] = '12345'
      role_form.validate role_params
      expect(role_form.errors[:code]).to include 'size cannot be greater than 4'
    end

    it 'is unique'
  end
end
