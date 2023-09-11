require 'rails_helper'

RSpec.describe 'Simple pages', app: :api_particulier do
  describe 'home' do
    it 'does not raise error' do
      visit root_path

      expect(page).to have_content('API Particulier')
    end
  end

  describe 'mentions' do
    it 'does not raise error' do
      expect {
        visit mentions_path
      }.not_to raise_error
    end
  end

  describe 'cgu' do
    it 'does not raise error' do
      expect {
        visit cgu_path
      }.not_to raise_error
    end
  end

  describe 'accessibilite' do
    it 'does not raise error' do
      expect {
        visit accessibilite_path
      }.not_to raise_error
    end
  end

  describe 'infolettre' do
    it 'does not raise error' do
      expect {
        visit newsletter_path
      }.not_to raise_error
    end

    it 'does not mention API Entreprise' do
      visit newsletter_path

      expect(page).not_to have_content('API Entreprise')
    end
  end

  describe 'account' do
    it 'does not raise error' do
      expect {
        visit '/compte'
      }.not_to raise_error

      expect(page).to have_content('API Particulier')
    end
  end

  describe 'developers redoc page', :js do
    it 'works and displays openapi container' do
      Capybara.using_wait_time 5 do
        expect {
          visit developers_openapi_path
        }.not_to raise_error

        expect(page).to have_content('Quotient familial')
      end
    end
  end
end
