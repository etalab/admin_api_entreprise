require 'rails_helper'

RSpec.describe JwtAPIEntrepriseExpirationNoticeJob do
  subject { described_class.perform_now }

  shared_examples 'sending expiration notices' do |nb_days|
    it "sends notifications for JWT expiration in #{nb_days} days" do
      notifier_spy = class_spy(JwtAPIEntreprise::Operation::NotifyExpiration)
      stub_const('JwtAPIEntreprise::Operation::NotifyExpiration', notifier_spy)

      subject

      expect(notifier_spy).to have_received(:call).with(expire_in: nb_days)
    end
  end

  it_behaves_like 'sending expiration notices', 90
  it_behaves_like 'sending expiration notices', 60
  it_behaves_like 'sending expiration notices', 30
  it_behaves_like 'sending expiration notices', 14
  it_behaves_like 'sending expiration notices', 0
end
