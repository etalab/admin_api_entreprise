# frozen_string_literal: true

RSpec.shared_examples 'a faq feature' do |api_module_class|
  it 'displays entries' do
    visit faq_index_path

    expect(page).to have_css('.faq-entry', count: api_module_class::FAQEntry.all.count)
  end

  it 'has a button to copy anchors on titles', :js do
    visit faq_index_path

    api_module_class::FAQEntry.all do |entry|
      expect(page).to have_css("#button-anchor-#{entry.category.parameterize}"),
        "Missing button copy-anchor on #{entry.category}"
    end
  end

  describe 'when the user is logged in' do
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
