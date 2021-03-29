require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    assign(:jwt_authorization_request_id, number)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey', formats: [:html]
  end

  let(:number) { Faker::Number.number(digits: 5) }

  let(:some_html_content) do
    <<~SOME_HTML_CONTENT.chomp
      quelle est votre satisfaction</strong> concernant votre
    SOME_HTML_CONTENT
  end

  subject do
    rendered
  end

  it 'renders some content with HTML tags' do
    expect(subject).to match some_html_content
  end

  it 'renders the JWT authorization request id' do
    expect(subject).to match "N°#{number}"
  end
end
