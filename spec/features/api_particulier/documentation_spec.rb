# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Documentation pages', app: :api_particulier do
  describe 'developers' do
    it 'does not raise error' do
      expect {
        visit developers_path
      }.not_to raise_error
    end
  end
end
