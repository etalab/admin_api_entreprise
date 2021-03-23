require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    render template: "jwt_api_entreprise_mailer/satisfaction_survey.#{format}.erb"
  end

  let(:embedded_form_truncated_content) do
    <<~EMBEDDED.chomp
      quelle est votre satisfaction</strong> concernant votre
    EMBEDDED
  end

  let(:link_to_the_form) do
    <<~LINK.chomp
      <a href="https://startupdetat.typeform.com/to/bFo1H9NJ">Répondre à l&#39;enquête utilisateur</a>
    LINK
  end

  subject do
    rendered
  end

  context 'when in HTML' do
    let(:format) { 'html' }

    it 'renders the message' do
      expect(subject).to match embedded_form_truncated_content
      expect(subject).not_to match link_to_the_form
    end
  end

  context 'when in plaintext' do
    let(:format) { 'text' }

    it 'renders the message' do
      expect(subject).not_to match embedded_form_truncated_content
      expect(subject).to match link_to_the_form
    end
  end
end
