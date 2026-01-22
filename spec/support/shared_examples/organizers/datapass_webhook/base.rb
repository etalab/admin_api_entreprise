# frozen_string_literal: true

RSpec.shared_examples 'a datapass webhook organizer' do |api_name, mailjet_list_id|
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    build(:datapass_webhook,
      event: 'approve',
      authorization_request_attributes: {
        copied_from_enrollment_id: previous_enrollment_id
      })
  end

  let(:previous_enrollment_id) { rand(9001).to_s }
  let(:token) { create(:token) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
    # No yield here - specific setups should be in the specs
  end

  it_behaves_like 'datapass webhooks'

  it "creates an authorization request with #{api_name} api" do
    expect(subject.authorization_request.api).to eq(api_name)
  end

  it 'creates token for API' do
    expect {
      subject
    }.to change(Token, :count).by(1)

    token = Token.find(subject.token_id)
    expect(token.api).to eq(api_name)
  end

  describe 'Mailjet adding contacts' do
    it "adds contacts to #{api_name.capitalize} mailjet list" do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        hash_including(id: Rails.application.credentials.public_send(mailjet_list_id)),
        any_args
      )

      subject
    end
  end
end
