# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/faq'

RSpec.describe 'FAQ & Support', app: :api_particulier do
  it_behaves_like 'a faq feature', APIParticulier
end
