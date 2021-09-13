require 'rails_helper'

RSpec.describe Contact do
  it 'has valid factories' do
    expect(build(:contact)).to be_valid
  end

  describe '.not_expired scope' do
    subject { Contact.not_expired }

    let!(:valid_contact) { create(:contact, jwt_api_entreprise: create(:jwt_api_entreprise, blacklisted: false, archived: false))}
    let!(:invalid_contact) { create(:contact, jwt_api_entreprise: create(:jwt_api_entreprise, blacklisted: false, archived: true))}

    it 'works' do
      expect(subject.count).to eq(1)
      expect(subject).to include(valid_contact)
    end
  end

  describe 'db columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:phone_number).of_type(:string) }
    it { is_expected.to have_db_column(:contact_type).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'db_indexes' do
    it { is_expected.to have_db_index(:created_at) }
  end

  describe 'relationships' do
    it { is_expected.to have_one(:jwt_api_entreprise) }
  end
end
