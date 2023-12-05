require 'rails_helper'

RSpec.describe 'FAQ & Support', app: :api_particulier do
  it 'displays entries' do
    visit faq_index_path

    expect(page).to have_css('.faq-entry', count: APIParticulier::FAQEntry.all.count)
  end

  it 'has a button to copy anchors on titles', :js do
    visit faq_index_path

    APIParticulier::FAQEntry.all do |entry|
      expect(page).to have_css("#button-anchor-#{entry.category.parameterize}"),
        "Missing button copy-anchor on #{entry.category}"
    end
  end

  describe 'non regression test: when the user is logged in' do
    let!(:user) { create(:user) }

    before do
      login_as(user)
    end

    it 'displays the page' do
      visit faq_index_path

      expect(page).to have_http_status(:success)
    end
  end
end
