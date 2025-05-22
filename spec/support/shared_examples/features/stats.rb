# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a stats feature' do |options = {}|
  # Extract required options
  stats_path_helper = options[:stats_path_helper] || :stats_path
  iframe_id = options[:iframe_id] || 'stats-api-entreprise'
  options[:api_name] || 'API Entreprise'

  describe "GET #{options[:api_name] || 'API'} stats" do
    before { visit send(stats_path_helper) }

    it 'renders the stats page' do
      expect(page).to have_css("iframe##{iframe_id}")
    end
  end
end
