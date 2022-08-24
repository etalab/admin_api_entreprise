require 'rails_helper'

RSpec.describe 'FAQ & Support', type: :feature, app: :api_entreprise do
  it 'displays entries' do
    visit faq_index_path

    expect(page).to have_css('.faq-entry', count: FAQEntry.all.count)
  end
end
