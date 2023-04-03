module SpecsHelper
  def api_particulier_example_uid
    'cnaf/quotient_familial'
  end

  def api_entreprise_example_uid
    'insee/unites_legales'
  end

  def api_entreprise_example_collection_uid
    'infogreffe/mandataires_sociaux'
  end

  def siret_valid
    '41816609600069'
  end

  def siren_valid
    siret_valid.first(9)
  end
end
