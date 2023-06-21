require 'rails_helper'

RSpec.describe UserAuthorizationRequestRole do
  let(:demandeur) { create(:user) }
  let(:contact_technique) { create(:user) }
  let(:contact_metier) { create(:user) }

  describe 'factory' do
    let(:user) { create(:user) }

    describe 'demandeur association' do
      subject { create(:user_authorization_request_role, :demandeur, user:) }

      it 'returns demandeur' do
        expect(subject.demandeur).to eq(user)
      end
    end

    describe 'contact_technique association' do
      subject { create(:user_authorization_request_role, :contact_technique, user:) }

      it 'returns contact technique' do
        expect(subject.contact_technique).to eq(user)
      end
    end

    describe 'contact_metier association' do
      subject { create(:user_authorization_request_role, :contact_metier, user:) }

      it 'returns contact metier' do
        expect(subject.contact_metier).to eq(user)
      end
    end
  end
end
