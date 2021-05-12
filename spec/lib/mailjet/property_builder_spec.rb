require 'rails_helper'

RSpec.describe Mailjet::PropertyBuilder do
  subject(:builder) do
    described_class.new(user)
  end

  let(:user) { create(:contact, type).jwt_api_entreprise.user }

  context 'when the contact is tech' do
    let(:type) { :tech }

    it 'returns the payload' do
      expect(builder.call).to eq(
        contact_demandeur:  false,
        contact_métier:     false,
        contact_technique:  true,
        techlettre:         true,
        infolettre:         true,
        origine:            'dashboard'
      )
    end
  end

  context 'when the contact is business' do
    let(:type) { :business }

    it 'returns the payload' do
      expect(builder.call).to eq(
        contact_demandeur:  false,
        contact_métier:     true,
        contact_technique:  false,
        techlettre:         false,
        infolettre:         true,
        origine:            'dashboard'
      )
    end
  end

  context 'when the contact is other' do
    let(:type) { :other }

    it 'returns the payload' do
      expect(builder.call).to eq(
        contact_demandeur:  true,
        contact_métier:     false,
        contact_technique:  false,
        techlettre:         false,
        infolettre:         true,
        origine:            'dashboard'
      )
    end
  end
end
