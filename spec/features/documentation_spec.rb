# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Documentation pages', type: :feature do
  describe 'developers' do
    it 'works' do
      expect {
        visit developers_path
      }.not_to raise_error
    end
  end

  describe 'guide migration' do
    it 'works' do
      expect {
        visit guide_migration_path
      }.not_to raise_error
    end
  end
end
