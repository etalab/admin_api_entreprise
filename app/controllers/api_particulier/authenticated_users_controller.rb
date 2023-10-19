class APIParticulier::AuthenticatedUsersController < APIParticulierController
  include AuthenticatedUserManagement

  helper_method :new_tokens_file_path

  def new_tokens_file_path
    file_path = Rails.root.join('./token_export')

    [
      "demarche_#{current_user.email}",
      "contact_technique_#{current_user.email}",
      "demandeur_#{current_user.email}"
    ].each do |filename|
      full_path = "#{file_path}/#{filename}.csv"
      return File.read(full_path) if File.exist?(full_path)
    end

    nil
  end
end
