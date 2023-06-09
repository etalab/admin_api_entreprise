class APIParticulier::FAQController < APIParticulierController
  def index
    @faq_entries_grouped_by_categories = APIParticulier::FAQEntry.grouped_by_categories
  end
end
