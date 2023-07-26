class APIParticulier::StatsController < APIParticulierController
  def index
    respond_to do |format|
      format.html
      format.json do
        render json: data_collection
      end
    end
  end

  private

  def data_collection
    [
      {
        name: 'Nombre de pièces justificatives transmises sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/e6d80db2-e947-4916-a487-4e040fecc511.json',
        type: 'application/json'
      },
      {
        name: 'Nombre de quotients familiaux transmis sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/8d977c80-a675-48ea-9d73-294290f6665a.json',
        type: 'application/json'
      },
      {
        name: 'Nombre de cartes étudiants transmises sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/a234b04f-26de-4607-b81b-fb7c5ff79b58.json',
        type: 'application/json'
      }
    ]
  end
end
