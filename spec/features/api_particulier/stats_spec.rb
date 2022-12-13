# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Entreprise stats', app: :api_particulier do
  describe 'GET API Particulier stats' do
    before { visit api_particulier_stats_path }

    it 'renders the stats page' do
      expect(page).to have_selector('iframe#stats-api-particulier')
    end
  end
end
