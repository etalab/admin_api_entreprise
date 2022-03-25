class FAQController < ApplicationController
  def index
    @faq_entries_grouped_by_entries = FAQEntry.grouped_by_categories
  end
end
