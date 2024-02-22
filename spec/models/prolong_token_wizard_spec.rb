require 'rails_helper'

RSpec.describe ProlongTokenWizard do
  it 'has a valid factory' do
    expect(build(:prolong_token_wizard)).to be_valid
  end

  describe 'scopes' do
    let!(:prolong_token_wizards) do
      [
        create(:prolong_token_wizard, status: nil),
        create(:prolong_token_wizard, status: 'owner', owner: 'watever'),
        create(:prolong_token_wizard, status: 'project_purpose', owner: 'watever', project_purpose: true),
        create(:prolong_token_wizard, status: 'contacts', owner: 'watever', project_purpose: true, contact_technique: true, contact_metier: true),
        create(:prolong_token_wizard, :prolonged),
        create(:prolong_token_wizard, :requires_update, status: 'updates_refused')
      ]
    end

    it 'has 4 unfinished prolong_token_wizards' do
      expect(described_class.not_finished.count).to eq(4)
    end
  end

  describe 'validations' do
    let(:prolong_token_wizard) { build(:prolong_token_wizard, status:, owner:, project_purpose:, contact_technique:, contact_metier:) }
    let(:status) { nil }
    let(:owner) { nil }
    let(:project_purpose) { nil }
    let(:contact_technique) { nil }
    let(:contact_metier) { nil }

    describe 'it checks presence of owner' do
      let(:status) { 'owner' }

      it 'is not valid' do
        expect(prolong_token_wizard).not_to be_valid
      end

      it 'is valid' do
        prolong_token_wizard.owner = 'watever'
        expect(prolong_token_wizard).to be_valid
      end
    end

    describe 'it checks presence of project_purpose' do
      let(:status) { 'project_purpose' }
      let(:owner) { 'watever' }

      it 'is not valid' do
        expect(prolong_token_wizard).not_to be_valid
      end

      it 'is valid when false' do
        prolong_token_wizard.project_purpose = false
        expect(prolong_token_wizard).to be_valid
      end

      it 'is valid when true' do
        prolong_token_wizard.project_purpose = true
        expect(prolong_token_wizard).to be_valid
      end
    end

    describe 'it checks presence of contacts' do
      let(:status) { 'contacts' }
      let(:owner) { 'watever' }
      let(:project_purpose) { true }

      it 'is not valid' do
        expect(prolong_token_wizard).not_to be_valid
      end

      it 'is valid when false' do
        prolong_token_wizard.contact_technique = false
        prolong_token_wizard.contact_metier = false
        expect(prolong_token_wizard).to be_valid
      end

      it 'is valid when true' do
        prolong_token_wizard.contact_technique = true
        prolong_token_wizard.contact_metier = true
        expect(prolong_token_wizard).to be_valid
      end
    end
  end
end
