# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/shared_examples/features/endpoints/index'

RSpec.describe 'Endpoints index', app: :api_entreprise do
  it_behaves_like 'an endpoints index feature', APIEntreprise
end
