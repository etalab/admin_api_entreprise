class APIEntreprise::DocumentationController < APIEntrepriseController
  layout 'api_entreprise/no_container'

  def developers
    @documentation_entries = DocumentationEntry.developers

    render 'index'
  end

  def guide_migration
    @documentation_entries = DocumentationEntry.guide_migration

    render 'index'
  end
end
