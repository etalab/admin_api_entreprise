FactoryBot.define do
  factory :entreprise do
    personne_morale_attributs do
      {
        raison_sociale: 'UMAD Corp'
      }
    end

    activite_principale do
      {
        code: '62.01Z',
        libelle: 'Programmation informatique'
      }
    end

    forme_juridique do
      {
        code: '5710',
        libelle: 'Société par actions simplifiée'
      }
    end

    categorie_entreprise { 'GE' }
  end
end
