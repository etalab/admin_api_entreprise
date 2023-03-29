class APIEntreprise::FAQController < APIEntrepriseController
  def index
    @faq_entries_grouped_by_categories = APIEntreprise::FAQEntry.grouped_by_categories
  end
end
