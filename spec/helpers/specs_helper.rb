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
    # Octo-technology
    '41816609600069'
  end

  def siret_invalid
    '4181660960006'
  end

  def siret_not_found
    '41816609600068'
  end
end
