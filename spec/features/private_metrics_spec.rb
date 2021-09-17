# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private metrics', type: :feature do
  it 'works' do
    expect {
      visit api_private_metrics_path
    }.not_to raise_error
  end
end
