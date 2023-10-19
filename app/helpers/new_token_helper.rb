module NewTokenHelper
  def new_token?
    file_path = Rails.root.join('./token_export')

    [
      "demarche_#{current_user.email}",
      "contact_technique_#{current_user.email}",
      "demandeur_#{current_user.email}"
    ].each do |filename|
      full_path = "#{file_path}/#{filename}.csv"
      return true if File.exist?(full_path)
    end

    false
  end
end
