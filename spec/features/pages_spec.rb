require 'rails_helper'

RSpec.describe 'Simple pages', type: :feature do
  describe 'mentions' do
    it 'works' do
      expect {
        visit mentions_path
      }.not_to raise_error
    end
  end

  describe 'cgu' do
    it 'works' do
      expect {
        visit cgu_path
      }.not_to raise_error
    end
  end

  describe 'developers redoc page', js: true do
    it 'works and displays redoc container' do
      expect {
        visit developers_redoc_path
      }.not_to raise_error

      expect(page).to have_content('siret')
    end
  end
end
