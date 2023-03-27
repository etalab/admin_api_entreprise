class APIEntreprise::DocumentationController < APIEntrepriseController
  layout 'api_entreprise/no_container'

  def developers
    @documentation_page = APIEntreprise::DocumentationPage.find('developers')

    render 'index'
  end

  def guide_migration
    @documentation_page = APIEntreprise::DocumentationPage.find('guide_migration')

    render 'index'
  end
end
