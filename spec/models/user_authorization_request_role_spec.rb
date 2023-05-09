require 'rails_helper'

RSpec.describe UserAuthorizationRequestRole do
  let(:demandeur) { create(:user) }
  let(:contact_technique) { create(:user) }
  let(:contact_metier) { create(:user) }

  describe 'validations' do
    subject { create(:user_authorization_request_role, :demandeur) }

    it { is_expected.to validate_uniqueness_of(:authorization_request_id).scoped_to(%i[user_id role]).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(%i[authorization_request_id role]).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:role).scoped_to(%i[authorization_request_id user_id]).case_insensitive }
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:authorization_request) }

    describe '.demandeur' do
      subject { create(:user_authorization_request_role, :demandeur, user:) }

      it 'returns demandeur' do
        expect(subject.demandeur).to eq(user)
      end
    end

    describe '.contact_technique' do
      subject { create(:user_authorization_request_role, :contact_technique, user:) }

      it 'returns contact technique' do
        expect(subject.contact_technique).to eq(user)
      end
    end

    describe '.contact_metier' do
      subject { create(:user_authorization_request_role, :contact_metier, user:) }

      it 'returns contact metier' do
        expect(subject.contact_metier).to eq(user)
      end
    end
  end
end
