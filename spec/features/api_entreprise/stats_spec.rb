# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Entreprise stats', app: :api_entreprise do
  describe 'GET API Entreprise stats' do
    before { visit stats_path }

    it 'renders the stats page' do
      expect(page).to have_selector('iframe#stats-api-entreprise')
    end
  end
end
