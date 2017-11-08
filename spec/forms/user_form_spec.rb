require 'rails_helper'

describe UserForm::Create do
  let(:user_form) { described_class.new User.new }
  let(:user_params) {
    {
      email: 'new@record.gg',
      context: 'very development',
      contacts: [
        { email: 'coucou@hello.fr', phone_number: '0123456789', contact_type: 'tech' },
        { email: 'supsup@hi.yo', phone_number: nil, contact_type: 'other' },
      ]
    }
  }

  context 'when params are valid' do
    it 'is valid' do
      user_form.validate user_params
      expect(user_form.errors).to be_empty
    end
  end

  describe '#email' do
    it 'is required' do
      user_params[:email] = nil
      user_form.validate user_params
      expect(user_form.errors[:email]).to include 'must be filled'
    end

    it 'has an email format' do
      user_params[:email] = 'very mail'
      user_form.validate user_params
      expect(user_form.errors[:email]).to include 'is in invalid format'
    end

    it 'is unique'
  end

  describe '#context' do
    it 'is not required' do
      user_params[:context] = nil
      user_form.validate user_params
      expect(user_form.errors[:context]).to be_empty
    end

    it 'is a string' do
      user_params[:context] = {}
      user_form.validate user_params
      expect(user_form.errors[:context]).to include 'must be a string'
    end
  end

  describe '#contacts' do
    it 'is not valid if contact data is not valid' do
      user_params[:contacts].append({ email: 'not an email' })
      expect(user_form.validate(user_params)).to be false
    end

    it 'is optionnal' do
      user_params.delete :contacts
      expect(user_form.validate user_params).to be true
    end
  end
end
