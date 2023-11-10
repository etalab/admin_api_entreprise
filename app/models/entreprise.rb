class Entreprise
  include ActiveModel::Model

  attr_accessor :personne_morale_attributs,
    :activite_principale,
    :forme_juridique,
    :categorie_entreprise

  def forme_juridique_libelle
    forme_juridique[:libelle]
  end

  def raison_sociale
    personne_morale_attributs[:raison_sociale]
  end

  def naf
    "#{activite_principale[:code]} - #{activite_principale[:libelle]}"
  end
end
