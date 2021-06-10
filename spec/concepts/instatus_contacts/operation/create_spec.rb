# frozen_string_literal: true

RSpec.describe InstatusContacts::Operation::Create do
  subject { described_class.call(params: {'id' => contact.id}) }

  before do
    contact.jwt_api_entreprise.roles << role
  end

  let(:email) { 'bob@contact.email' }
  let(:contact) { create(:contact, :tech, email: email) }
  let(:role) { build(:role, code: Rails.application.config_for(:instatus).dig(:components).keys.sample) }

  it 'is serialized and posted to Instatus' do
    expect_any_instance_of(InstatusClient::AddASubscriber).to receive(:call) do
      OpenStruct.new(
        code: '200',
        body: [{ email: email }].to_json
      )
    end

    is_expected.to be_a_success
  end
end
