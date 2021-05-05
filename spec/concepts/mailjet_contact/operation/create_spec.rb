require 'rails_helper'

RSpec.describe MailjetContacts::Operation::Create do
  subject { described_class.call }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
    create(:user, created_at: created_date)
  end

  context 'when users were added a long time ago' do
    let(:created_date) { 2.years.ago }

    it { is_expected.to be_a_failure }
  end

  context 'when users were recently added' do
    let(:created_date) { 2.minutes.ago }

    it { is_expected.to be_a_success }
  end
end
