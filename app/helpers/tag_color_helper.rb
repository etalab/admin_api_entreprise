module TagColorHelper
  def user_type_tag_color(user_type)
    case user_type
    when 'administrations'
      'pink-tuile'
    when 'collectivités'
      'pink-macaron'
    when 'régions'
      'pink-macaron'
    when 'départements'
      'pink-macaron'
    when 'intercommunalités'
      'pink-macaron'
    when 'communes'
      'pink-macaron'
    when 'éditeurs de logiciels'
      'green-archipel'
    else
      'brown-cafe-creme'
    end
  end
end
