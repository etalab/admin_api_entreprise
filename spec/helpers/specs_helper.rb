module SpecsHelper
  def example_uid
    'insee/unites_legales'
  end

  def example_collection_uid
    'infogreffe/mandataires_sociaux'
  end

  def siret_valid
    '41816609600069'
  end

  def siren_valid
    siret_valid.first(9)
  end
end
