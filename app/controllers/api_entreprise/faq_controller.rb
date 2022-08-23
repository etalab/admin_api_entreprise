class APIEntreprise::FAQController < APIEntrepriseController
  def index
    @faq_entries_grouped_by_categories = FAQEntry.grouped_by_categories
  end
end
