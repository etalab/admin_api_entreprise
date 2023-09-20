require 'rails_helper'

RSpec.describe 'FAQ & Support', app: :api_entreprise do
  before do
    visit faq_index_path
  end

  it 'displays entries' do
    expect(page).to have_css('.faq-entry', count: APIEntreprise::FAQEntry.all.count)
  end

  it 'has a button to copy anchors on titles', :js do
    APIEntreprise::FAQEntry.all do |entry|
      expect(page).to have_css("#button-anchor-#{entry.category.parameterize}"),
        "Missing button copy-anchor on #{entry.category}"
    end
  end

  describe 'algolia search', :js do
    subject do
      visit faq_index_path

      within('#faq_search_input') do
        find('input[type="search"]').set('combien coûte')
      end
    end

    it 'filters entries' do
      subject

      expect(page).to have_css('.faq-entry', count: 1)
      expect(page).to have_css('#api_entreprise_faq_entry_combien-coute-l-api-entreprise')
    end
  end
end
