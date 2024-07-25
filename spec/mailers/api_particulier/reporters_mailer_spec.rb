RSpec.describe APIParticulier::ReportersMailer do
  before do
    create(:user, email: 'user@yopmail.com')
  end

  describe '#submit' do
    subject(:mail) do
      described_class.with(group: 'cnaf').submit
    end

    it 'sends an email to reporters associated to this group' do
      expect(mail.to).to include('user@yopmail.com')
    end
  end
end
