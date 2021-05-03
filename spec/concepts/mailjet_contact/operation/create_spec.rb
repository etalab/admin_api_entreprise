require 'rails_helper'

RSpec.describe MailjetContact::Operation::Create do
  subject(:call!) { described_class.call }

  before do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield(http)

    response = double
    allow(http).to receive(:request).and_return(response)
    allow(response).to receive(:code).and_return('200')
  end

  let!(:user) { create(:user, created_at: created_date) }

  context 'when a user was added a long time ago' do
    let(:created_date) { 2.years.ago }

    it { is_expected.to be_a_failure }
  end

  context 'when a user has been added recently' do
    let(:created_date) { 2.minutes.ago }

    it { is_expected.to be_a_success }
  end
end
