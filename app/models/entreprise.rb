class Entreprise
  include ActiveModel::Model

  attr_accessor :raison_sociale,
    :naf_entreprise,
    :libelle_naf_entreprise,
    :forme_juridique,
    :categorie_entreprise
end
