require 'rails_helper'

RSpec.describe 'Homepage', app: :api_entreprise do
  describe 'when clicking on a partner logo' do
    let(:url_with_filtering) { "#{endpoints_path}?APIEntreprise_Endpoint%5Bquery%5D=infogreffe" }

    it 'redirects to catalogue' do
      visit root_path
      click_link 'link_infogreffe'

      expect(page).to have_current_path(url_with_filtering)
    end

    it 'filters on partner', js: true do
      visit url_with_filtering

      expect(page).to have_css('#api_entreprise_endpoint_infogreffe_mandataires_sociaux')
      expect(page).to have_css('.endpoint-card', count: 2)
    end
  end
end
