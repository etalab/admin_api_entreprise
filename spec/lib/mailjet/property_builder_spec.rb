require 'rails_helper'

RSpec.describe Mailjet::PropertyBuilder do
  subject(:builder) do
    described_class.new(user)
  end

  let(:jwt_api_entreprise) { create(:jwt_api_entreprise) }
  let(:user) { create(:jwt_api_entreprise).user }

  it 'has the default properties' do
    expect(builder.call).to eq(
      contact_demandeur:  false,
      contact_métier:     false,
      contact_technique:  false,
      techlettre:         false,
      infolettre:         true,
      origine:            'dashboard'
    )
  end

  context 'when a tech contact is present' do
    before { create(:contact, :tech, jwt_api_entreprise: jwt_api_entreprise) }

    it 'enables additional tech properties' do
      expect(builder.call).to eq(
        contact_demandeur:  false,
        contact_métier:     false,
        contact_technique:  true,
        techlettre:         true,
        infolettre:         true,
        origine:            'dashboard'
      )
    end

    context 'when a business contact is also present' do
      before { create(:contact, :business, jwt_api_entreprise: jwt_api_entreprise) }

      it 'enables additional business properties' do
        expect(builder.call).to eq(
          contact_demandeur:  false,
          contact_métier:     true,
          contact_technique:  true,
          techlettre:         true,
          infolettre:         true,
          origine:            'dashboard'
        )
      end

      context 'when another contact is also present' do
        before { create(:contact, :other, jwt_api_entreprise: jwt_api_entreprise) }

        it 'enables additional other properties' do
          expect(builder.call).to eq(
            contact_demandeur:  true,
            contact_métier:     true,
            contact_technique:  true,
            techlettre:         true,
            infolettre:         true,
            origine:            'dashboard'
          )
        end
      end
    end
  end
end
