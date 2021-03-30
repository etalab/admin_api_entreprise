require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    assign(:jwt_authorization_request_id, number)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey', formats: [:html]
  end

  let(:number) { Faker::Number.number(digits: 5) }

  subject do
    rendered
  end

  it 'renders the JWT authorization request id' do
    expect(subject).to match "N°#{number}"
  end
end
