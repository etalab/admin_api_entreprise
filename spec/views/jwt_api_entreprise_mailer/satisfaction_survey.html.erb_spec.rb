require 'rails_helper'

RSpec.describe('rendering the mail template') do
  let(:jwt) { build(:jwt_api_entreprise) }

  before do
    assign(:jwt, jwt)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey', formats: [:html]
  end

  subject do
    rendered
  end

  it 'renders the JWT authorization request id' do
    expect(subject).to(match("n°#{jwt.authorization_request_id}"))
  end
end
