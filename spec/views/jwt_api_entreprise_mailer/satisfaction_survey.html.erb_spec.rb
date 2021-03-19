require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    assign(:full_name, full_name)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey.html.erb'
  end

  context 'with a name' do
    let(:full_name) { 'Bob MARTIN' }

    it { expect(rendered).to match /Bonjour Bob MARTIN,/ }
  end

  context 'without a name' do
    let(:full_name) { nil }

    it { expect(rendered).to match /Bonjour,/ }
  end
end
