class APIParticulier::NewTokensController < APIParticulier::AuthenticatedUsersController
  def download
    file = new_tokens_file_path

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
end
