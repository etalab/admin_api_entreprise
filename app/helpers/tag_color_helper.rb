module TagColorHelper
  def user_type_tag_color(user_type)
    case user_type
    when 'administrations'
      'pink-tuile'
    when 'collectivités', 'régions', 'départements', 'intercommunalités', 'communes'
      'pink-macaron'
    when 'éditeurs de logiciels'
      'green-archipel'
    when 'modalité d’appel'
      'blue-cumulus'
    else
      'brown-cafe-creme'
    end
  end
end
