require 'rails_helper'

RSpec.describe Mailjet::ContactPropertiesAdapter do
  subject(:builder) do
    described_class.new(user)
  end

  let(:jwt_api_entreprise) { create(:jwt_api_entreprise) }
  let(:user) { jwt_api_entreprise.user }

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

  context 'when looking at role properties' do
    subject(:role_propreties) do
      builder.call.select { |k, _v| k.start_with?('role_') }
    end

    let!(:role) { create(:role, code: role_code) }

    context 'when the role is not declared on Mailjet as a property' do
      describe '#uptime' do
        let(:role_code) { 'uptime' }

        context 'when the role is enabled on the JWT' do
          before do
            jwt_api_entreprise.roles << create(:role, code: role_code)
          end

          it { expect(role_propreties.dig("role_#{role_code}".to_sym)).to be nil }
        end

        context 'when the role is disabled on the JWT' do
          before do
            jwt_api_entreprise.roles.where(code: role_code).delete_all
          end

          it { expect(role_propreties.dig("role_#{role_code}".to_sym)).to be nil }
        end
      end
    end

    context 'when the role is declared on Mailjet as a property' do
      describe '#certificat_opqibi' do
        let(:role_code) { 'certificat_opqibi' }

        context 'when the role is enabled on the JWT' do
          before do
            jwt_api_entreprise.roles << role
          end

          it { expect(role_propreties.dig("role_#{role_code}".to_sym)).to be true }
        end

        context 'when the role is disabled on the JWT' do
          before do
            jwt_api_entreprise.roles.delete_all
          end

          it { expect(role_propreties.dig("role_#{role_code}".to_sym)).to be false }
        end
      end
    end
  end
end
