# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/documentation'

RSpec.describe 'Documentation pages', app: :api_entreprise do
  it_behaves_like 'a documentation feature'
end
