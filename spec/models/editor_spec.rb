RSpec.describe Editor do
  it 'has a valid factory' do
    expect(build(:editor)).to be_valid
  end

  describe 'authorization_requests association' do
    subject { editor.authorization_requests(api:) }

    let(:editor) { create(:editor, form_uids: %w[form1 form2]) }
    let(:api) { 'entreprise' }

    let!(:valid_authorization_requests) do
      [
        create(:authorization_request, api: 'entreprise', demarche: 'form1'),
        create(:authorization_request, api: 'entreprise', demarche: 'form2')
      ]
    end

    let!(:invalid_authorization_requests) do
      [
        create(:authorization_request, api: 'entreprise', demarche: 'wrong_form'),
        create(:authorization_request, api: 'particulier', demarche: 'form1')
      ]
    end

    it { is_expected.to match_array(valid_authorization_requests) }
    it { is_expected.to be_a(ActiveRecord::Relation) }
  end
end
