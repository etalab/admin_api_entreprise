# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Particulier stats', app: :api_particulier do
  it_behaves_like 'a stats feature',
    stats_path_helper: :api_particulier_stats_path,
    iframe_id: 'stats-api-particulier',
    api_name: 'API Particulier'
end
