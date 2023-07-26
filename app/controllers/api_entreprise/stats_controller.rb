class APIEntreprise::StatsController < APIEntrepriseController
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
        name: 'Nombre d\'appels pour une unité légale sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/021a0118-2071-416c-8527-e76e350b1d03.json',
        type: 'application/json'
      },
      {
        name: 'Nombre d\'appels totaux sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/b3923a04-55d3-4c79-a035-201a6d0e2d13.json',
        type: 'application/json'
      },
      {
        name: 'Nombre d\'appels uniques sur les 2 derniers mois',
        url: 'https://metabase.entreprise.api.gouv.fr/public/question/f62b61aa-227e-4f0e-b9f0-605913771cde.json',
        type: 'application/json'
      }
    ]
  end
end
