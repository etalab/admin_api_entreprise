require 'rails_helper'

RSpec.describe 'datapass webhook trigger mails', type: :request do
  include ActiveJob::TestHelper

  let(:datapass_webhook_params) { build(:datapass_webhook, event: 'validate_application') }

  let(:headers) do
    {
      'Host' => 'entreprise.api.whatever.com'
    }
  end

  describe 'on API Entreprise', app: :api_entreprise do
    subject do
      post api_datapass_api_entreprise_webhook_path, params: datapass_webhook_params, headers:
    end

    let(:email) { ActionMailer::Base.deliveries.last }
    let(:demandeur) do
      datapass_webhook_params['data']['pass']['team_members'].find { |team_member| team_member['job'] == 'Demandeur' }
    end

    before do
      allow_any_instance_of(HubSignature).to receive(:valid?).and_return(true) # rubocop:todo RSpec/AnyInstance

      stub_request(:post, 'https://api.mailjet.com/v3/REST/contactslist/9001/managemanycontacts')
        .to_return(status: 200, body: '', headers: {})

      allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
    end

    it { is_expected.to eq(200) }

    it 'delivers an email' do
      perform_enqueued_jobs do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(email.to).to eq([demandeur['email']])
      end
    end
  end
end
