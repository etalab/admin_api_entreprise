# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/cas_usages'

RSpec.describe 'Cas usages pages', app: :api_particulier do
  it_behaves_like 'a cas usages feature', APIParticulier, 'api_particulier'
end
