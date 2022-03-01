module SpecsHelper
  def example_uid
    'insee/unites_legales'
  end

  def example_collection_uid
    'infogreffe/mandataires_sociaux'
  end

  def apientreprise_test_token
    File.read('spec/fixtures/apientreprise_test_token')
  end

  def siret_valid
    octo_technology_siret
  end
  
  def octo_technology_siret
    '41816609600069'
  end

  def siret_invalid
    '4181660960006'
  end

  def siret_not_found
    '41816608600068'
  end

  def siren_valid
    siret_valid.first(9)
  end

  def siren_invalid
    siret_invalid.first(9)
  end

  def siren_not_found
    siret_not_found.first(9)
  end
end
