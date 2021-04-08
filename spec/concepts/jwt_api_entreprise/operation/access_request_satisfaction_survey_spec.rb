require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey do
  subject(:call!) { described_class.call }


  context 'when the JWT is less than 7 days old' do
    let!(:token) { create(:jwt_api_entreprise, :less_than_seven_days_ago) }

    it { is_expected.to be_a_failure }

    it 'does not send the survey' do
      expect { call! }
        .not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
    end

    it 'does not change the JWT state' do
      expect { call! }
        .to_not change(token, :access_request_survey_sent)
    end
  end

  context 'when the JWT is 7 days old or more' do
    let!(:token) { create(:jwt_api_entreprise, :seven_days_ago, sent_state, blacklisted_or_not_blacklisted) }

    context 'when the survey has not been sent yet' do
      let(:sent_state) { :access_request_survey_not_sent }

      context 'when the token is blacklisted' do
        let(:blacklisted_or_not_blacklisted) { :blacklisted }

        it { is_expected.to be_a_failure }

        it 'does not send the survey' do
          expect { call! }
            .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
        end

        it 'does not change the JWT state' do
          expect { call! }
            .to_not change(token, :access_request_survey_sent)
        end
      end

      context 'when the token is not blacklisted' do
        let(:blacklisted_or_not_blacklisted) { :not_blacklisted }

        it { is_expected.to be_a_success }

        it 'sends an email survey' do
          expect { call! }
            .to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
            .with(args: [token])
        end

        it 'saves that the survey was sent' do
          expect do
            call!
            token.reload
          end
            .to change(token, :access_request_survey_sent).from(false).to(true)
        end
      end
    end

    context 'when the survey was already sent' do
      let(:sent_state) { :access_request_survey_sent }

      context 'when the token is blacklisted' do
        let(:blacklisted_or_not_blacklisted) { :blacklisted }

        it { is_expected.to be_a_failure }

        it 'does not send it again' do
          expect {
            call!
          }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
        end

        it 'does not change the JWT state' do
          expect { call! }
            .to_not change(token, :access_request_survey_sent)
        end
      end

      context 'when the token is not blacklisted' do
        let(:blacklisted_or_not_blacklisted) { :not_blacklisted }

        it { is_expected.to be_a_failure }

        it 'does not send it again' do
          expect {
            call!
          }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
        end

        it 'does not change the JWT state' do
          expect { call! }
            .to_not change(token, :access_request_survey_sent)
        end
      end
    end
  end
end
