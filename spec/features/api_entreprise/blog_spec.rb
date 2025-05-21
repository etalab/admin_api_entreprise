# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/blog'

RSpec.describe 'Blog', app: :api_entreprise do
  it_behaves_like 'a blog feature'
end
