# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Entreprise stats', app: :api_entreprise do
  it_behaves_like 'a stats feature',
    stats_path_helper: :stats_path,
    iframe_id: 'stats-api-entreprise',
    api_name: 'API Entreprise'
end
