require 'rails_helper'

describe JwtApiEntreprise::Operation::NotifyExpiration do
  describe 'delay: option (provide a number of days)' do
    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }
    let(:user_3) { create(:user) }

    # Let's test with a 90 days (3 months) expiration notice
    # Two tokens on the three are targetted
    before do
      create(:jwt_expiring_in_3_month, user: user_1)
      create(:jwt_expiring_in_3_month, user: user_2)
      create(:jwt_expiring_in_1_year, user: user_3)
    end

    subject { described_class.call(delay: 90) }

    it { is_expected.to be_success }

    it 'sends emails with JwtApiEntrepriseMailer' do
      expect(JwtApiEntrepriseMailer).to receive(:expiration_notice).twice.and_call_original

      subject
    end

    it 'sends emails to the related tokens owners' do
      subject

      expect(ActionMailer::Base.deliveries).to include(
        an_object_having_attributes(to: a_collection_including(user_1.email)),
        an_object_having_attributes(to: a_collection_including(user_2.email)),
      )
    end

    it 'does not send the same notification twice' do
      described_class.call(delay: 90)

      expect { described_class.call(delay: 90) }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it 'saves the notification has been sent' do
      subject
      expiring_jwt = user_1.jwt_api_entreprise.first

      expect(expiring_jwt.days_left_notification_sent).to include(90)
    end
  end

  context 'when delay: is not specified' do
    it 'raises an error' do
      expect { described_class.call }.to raise_error(ArgumentError, a_string_matching(/missing keyword: delay/))
    end
  end
end
