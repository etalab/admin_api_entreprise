require 'rails_helper'

describe JwtApiEntreprise::Operation::NotifyExpiration do
  describe 'expire_in: option (provide a number of days)' do
    # Let's test with a 90 days (3 months) expiration notice
    # Two tokens on the three are targetted
    let(:days) { 90 }

    let!(:jwt_1) { create(:jwt_api_entreprise, :expiring_within_3_month) }
    let!(:jwt_2) { create(:jwt_api_entreprise, :expiring_within_3_month) }
    let!(:jwt_3) { create(:jwt_api_entreprise, :expiring_in_1_year) }

    subject { described_class.call(expire_in: days) }

    it { is_expected.to be_success }

    it 'calls the mailer for the affected JWT only' do
      expect(JwtApiEntrepriseMailer).to receive(:expiration_notice).with(jwt_1, days).and_call_original
      expect(JwtApiEntrepriseMailer).to receive(:expiration_notice).with(jwt_2, days).and_call_original
      expect(JwtApiEntrepriseMailer).to_not receive(:expiration_notice).with(jwt_3, days).and_call_original

      subject
    end

    it 'does not send the same notification twice' do
      described_class.call(expire_in: days)
      expect(JwtApiEntrepriseMailer).to_not receive(:expiration_notice).with(jwt_1, days)
      expect(JwtApiEntrepriseMailer).to_not receive(:expiration_notice).with(jwt_2, days)

      subject
    end

    it 'saves that the notification has been sent' do
      subject
      jwt_1.reload
      jwt_2.reload

      expect([jwt_1, jwt_2]).to all(have_attributes(days_left_notification_sent: a_collection_including(days)))
    end
  end

  context 'when expire_in: is not specified' do
    it 'raises an error' do
      expect { described_class.call }.to raise_error(ArgumentError, a_string_matching(/missing keyword: expire_in/))
    end
  end
end
