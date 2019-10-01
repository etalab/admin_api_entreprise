require 'rails_helper'

describe Contact do
  describe 'db columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:phone_number).of_type(:string) }
    it { is_expected.to have_db_column(:contact_type).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:jwt_api_entreprise) }
  end
end
