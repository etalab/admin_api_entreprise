require 'rails_helper'

describe Contact, type: :model do
  let(:contact) { create :contact }

  context 'when attributes are valid' do
    subject { contact }

    it { is_expected.to be_valid }
    it { is_expected.to be_persisted }
  end

  describe '#email' do
    it 'is required' do
      contact.email = nil
      contact.valid?
      expect(contact.errors[:email].size).to be >= 1
    end

    it 'has an email format' do
      contact.email = 'not_@n_email'
      contact.valid?
      expect(contact.errors[:email].size).to eq 1
    end
  end

  describe '#phone_number' do
    it 'is not required' do
      contact.phone_number = ''
      expect(contact).to be_valid
    end

    it 'does not accept not french format' do
      contact.phone_number = '202-555-0110'
      contact.valid?
      expect(contact.errors[:phone_number].size).to eq 1
    end
  end

  describe '#contact_type' do
    it 'is required' do
      contact.contact_type = nil
      contact.valid?
      expect(contact.errors[:contact_type].size).to be >= 1
    end

    it 'accepts "tech" value' do
      contact.contact_type = 'tech'
      expect(contact).to be_valid
    end

    it 'accepts "admin" value' do
      contact.contact_type = 'admin'
      expect(contact).to be_valid
    end

    it 'accepts "other" value' do
      contact.contact_type = 'other'
      expect(contact).to be_valid
    end

    it 'does not accept another value' do
      contact.contact_type = 'not a valid value'
      contact.valid?
      expect(contact.errors[:contact_type].size).to eq 1
    end
  end
end
