class APIParticulier::NewTokensController < APIParticulier::AuthenticatedUsersController
  def download
    file = get_file_content(current_user.email)

    if file.present?
      send_data file, filename: 'nouveaux_jetons.csv'
    else
      flash_message(
        :error,
        title: 'Erreur lors de la recherche',
        description: 'Il n\'existe aucun nouveau jeton pour votre compte',
        id: 'error-no-token'
      )

      redirect_to user_profile_path
    end
  end

  private

  def get_file_content(email)
    file_path = Rails.root.join('./token_export')

    [
      "demarche_#{email}",
      "contact_technique_#{email}",
      "demandeur_#{email}"
    ].each do |filename|
      full_path = "#{file_path}/#{filename}.csv"
      return File.read(full_path) if File.exist?(full_path)
    end

    nil
  end
end
