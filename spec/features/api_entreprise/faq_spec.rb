require 'rails_helper'

RSpec.describe 'FAQ & Support', app: :api_entreprise do
  before do
    visit faq_index_path
  end

  it 'displays entries' do
    expect(page).to have_css('.faq-entry', count: APIEntreprise::FAQEntry.all.count)
  end

  it 'has a button to copy anchors on titles', js: true do
    APIEntreprise::FAQEntry.all do |entry|
      expect(page).to have_css("#button-anchor-#{entry.category.parameterize}"),
        "Missing button copy-anchor on #{entry.category}"
    end
  end
end
