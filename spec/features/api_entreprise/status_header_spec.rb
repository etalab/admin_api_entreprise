require 'rails_helper'

RSpec.describe 'Status header', app: :api_entreprise, js: true do
  before do
    allow_any_instance_of(StatusPage).to receive(:current_status).and_return(:up) # rubocop:todo RSpec/AnyInstance
  end

  it 'displays status on home page' do
    visit root_path

    expect(page).to have_css('#current_status .circle.circle-success')
  end
end
