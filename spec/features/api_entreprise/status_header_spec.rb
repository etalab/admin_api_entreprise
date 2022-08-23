require 'rails_helper'

RSpec.describe 'Status header', type: :feature, app: :api_entreprise, js: true do
  before do
    allow_any_instance_of(StatusPage).to receive(:current_status).and_return(:up)
  end

  it 'displays status on home page' do
    visit root_path

    expect(page).to have_css('#current_status .circle.circle-success')
  end
end
