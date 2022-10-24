# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Documentation pages', app: :api_entreprise do
  describe 'developers' do
    it 'does not raise error' do
      expect {
        visit developers_path
      }.not_to raise_error
    end
  end

  describe 'guide migration' do
    it 'does not raise error' do
      expect {
        visit guide_migration_path
      }.not_to raise_error
    end
  end
end
