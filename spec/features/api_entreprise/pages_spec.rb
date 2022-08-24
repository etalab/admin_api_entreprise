require 'rails_helper'

RSpec.describe 'Simple pages', type: :feature, app: :api_entreprise do
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

  describe 'infolettre' do
    it 'works' do
      expect {
        visit newsletter_path
      }.not_to raise_error
    end
  end

  describe 'developers redoc page', js: true do
    it 'works and displays openapi container' do
      Capybara.using_wait_time 5 do
        expect {
          visit developers_openapi_path
        }.not_to raise_error

        expect(page).to have_content('siret')
      end
    end
  end
end
