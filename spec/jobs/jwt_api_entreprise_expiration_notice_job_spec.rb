require 'rails_helper'

describe JwtApiEntrepriseExpirationNoticeJob do
  subject { described_class.perform_now }

  shared_examples 'sending expiration notices' do |nb_days|
    it "sends notifications for JWT expiration in #{nb_days} days" do
      expect(JwtApiEntreprise::Operation::NotifyExpiration)
        .to receive(:call)
        .with(expire_in: nb_days)

      subject
    end
  end

  it_behaves_like 'sending expiration notices', 90
end
