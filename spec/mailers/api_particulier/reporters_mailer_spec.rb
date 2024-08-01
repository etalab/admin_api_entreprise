RSpec.describe APIParticulier::ReportersMailer do
  before do
    create(:user, email: 'user@yopmail.com')
  end

  describe '#submit' do
    subject(:mail) do
      described_class.with(groups: %w[cnaf_ men_]).submit
    end

    it 'sends an email to reporters associated to these groups' do
      expect(mail.bcc).to include('user@yopmail.com')
      expect(mail.bcc).to include('api-particulier@yopmail.com')
      expect(mail.bcc).not_to include('datapass@yopmail.com')
    end
  end
end
