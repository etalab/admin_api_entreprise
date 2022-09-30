module TagColorHelper
  def user_type_tag_color(user_type)
    case user_type
    when 'administrations'
      'green-emeraude'
    when 'collectivités'
      'green-menthe'
    when 'éditeurs de logiciels'
      'orange-terre-battue'
    else
      'brown-cafe-creme'
    end
  end
end
