require 'rails_helper'

RSpec.shared_examples 'static pages feature' do |options = {}|
  # Pages common to both APIs
  common_path_helpers = %i[mentions_path cgu_path donnees_personnelles_path accessibilite_path newsletter_path]

  # Common pages tests
  common_path_helpers.each do |path_helper|
    describe path_helper.to_s.gsub('_path', '') do
      it 'does not raise error' do
        expect {
          visit send(path_helper)
        }.not_to raise_error
      end
    end
  end

  # Configure API-specific content checks
  if options[:check_newsletter_content]
    describe 'infolettre content' do
      it "mentions #{options[:expected_api_name]} and not #{options[:unexpected_api_name]}" do
        visit newsletter_path

        expect(page).to have_content(options[:expected_api_name])
        expect(page).to have_no_content(options[:unexpected_api_name])
      end
    end
  end

  # Optional root path check with API name
  if options[:check_root_content]
    describe 'home' do
      it 'does not raise error and shows correct API name' do
        visit root_path

        expect(page).to have_content(options[:expected_api_name])
      end
    end
  end

  # Account page check if provided
  if options[:check_account_page]
    describe 'account' do
      it 'does not raise error and shows correct API name' do
        expect {
          visit '/compte'
        }.not_to raise_error

        expect(page).to have_content(options[:expected_api_name])
      end
    end
  end

  # Optional developers page with custom content check
  describe 'developers redoc page', :js do
    it 'works and displays expected content' do
      Capybara.using_wait_time 5 do
        expect {
          visit developers_openapi_path
        }.not_to raise_error

        expect(page).to have_content(options[:developers_content]) if options[:developers_content]
      end
    end
  end

  # Additional custom pages
  options[:additional_pages]&.each do |page_config|
    describe page_config[:name] do
      it 'does not raise error' do
        expect {
          if page_config[:path_helper]
            visit send(page_config[:path_helper])
          else
            visit page_config[:path]
          end
        }.not_to raise_error

        expect(page).to have_content(page_config[:content]) if page_config[:content]
      end
    end
  end
end
