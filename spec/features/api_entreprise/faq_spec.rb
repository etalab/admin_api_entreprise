# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/faq'

RSpec.describe 'FAQ & Support', app: :api_entreprise do
  it_behaves_like 'a faq feature', APIEntreprise
end
