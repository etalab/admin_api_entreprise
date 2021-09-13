require 'rails_helper'

RSpec.describe AuthorizationRequest, type: :model do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
  end

  describe 'contacts associations' do
    let(:authorization_request) { create(:authorization_request, :with_contacts) }

    it 'works' do
      expect(authorization_request.contacts.count).to eq(2)

      expect(authorization_request.contact_technique).to be_present
      expect(authorization_request.contact_metier).to be_present
    end
  end
end
