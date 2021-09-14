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

  describe '#editor_name' do
    subject { authorization_request.editor_name }

    let(:authorization_request) { build(:authorization_request, editor: editor) }

    context 'without editor' do
      let(:editor) { nil }

      it { is_expected.to be_nil }
    end

    context 'with editor' do
      context 'when it is present in editor config' do
        let(:editor) { 'provigis' }

        it 'takes name from config' do
          is_expected.to eq('Provigis')
        end
      end
    end
  end
end
