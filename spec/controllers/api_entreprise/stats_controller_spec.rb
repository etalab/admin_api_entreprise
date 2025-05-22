# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/controllers/stats_controller'

RSpec.describe APIEntreprise::StatsController do
  it_behaves_like 'a stats controller'
end
