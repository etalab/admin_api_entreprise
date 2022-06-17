require 'rails_helper'

RSpec.describe 'FAQ & Support', type: :feature do
  it 'displays entries' do
    visit faq_index_path

    expect(page).to have_css('.faq-entry', count: FAQEntry.all.count)
  end
end
