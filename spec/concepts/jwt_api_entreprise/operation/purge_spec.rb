require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::Purge do
  subject(:purge!) { described_class.call }

  context 'when a JWT has expired' do
    let!(:jwt) { create(:jwt_api_entreprise, :with_contacts, exp: 1.hour.ago.to_i) }

    it 'is deleted' do
      purge!

      expect { JwtApiEntreprise.find(jwt.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when a JWT has not expired yet' do
    let!(:jwt) { create(:jwt_api_entreprise, exp: 1.hour.from_now.to_i) }

    it 'is not deleted' do
      purge!

      expect(JwtApiEntreprise.find(jwt.id)).to eq(jwt)
    end
  end
end
