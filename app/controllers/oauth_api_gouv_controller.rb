class OAuthApiGouvController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:login]

  def login
    signin = OAuthApiGouv::Operation::Login.call(params: params)

    if signin.success?
      access_token = signin[:dashboard_token]
      render(json: { access_token: access_token }, status: 200)
    else
      final_state = signin.event.to_h[:semantic]

      if final_state == :unknown_user
        render(json: { errors: 'Utilisateur inconnu du service API Entreprise.' }, status: 422)
      elsif final_state == :invalid_authorization_code
        render(json: { errors: 'Erreur lors de l\'authentification : authorization code invalide.' }, status: 401)
      elsif final_state == :invalid_params
        err = signin['result.contract.default'].errors
        render(json: { errors: err }, status: 422)
      elsif final_state == :failure
        render(json: { errors: 'Une erreur est survenue lors des échanges avec OAuth API Gouv. Contactez API Entreprise à support@entreprise.api.gouv.fr si le problème persiste.' }, status: 502)
      end
    end
  end
end
