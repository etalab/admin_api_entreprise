require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    assign(:full_name, full_name)
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

    context 'with a name' do
      let(:full_name) { 'Bob MARTIN' }

      it { expect(subject).to match /Bonjour Bob MARTIN,/ }
    end

    context 'without a name' do
      let(:full_name) { nil }

      it { expect(subject).to match /Bonjour,/ }
    end

    after do
      expect(subject).to match embedded_form_truncated_content
      expect(subject).not_to match link_to_the_form
    end
  end

  context 'when in plaintext' do
    let(:format) { 'text' }

    context 'with a name' do
      let(:full_name) { 'Bob MARTIN' }

      it { expect(subject).to match /Bonjour Bob MARTIN,/ }
    end

    context 'without a name' do
      let(:full_name) { nil }

      it { expect(subject).to match /Bonjour,/ }
    end

    after do
      expect(subject).not_to match embedded_form_truncated_content
      expect(subject).to match link_to_the_form
    end
  end
end
