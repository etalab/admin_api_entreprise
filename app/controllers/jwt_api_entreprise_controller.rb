class JwtAPIEntrepriseController < AuthenticatedUsersController
  def index
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)
  end

  def create_magic_link
    send_magic_link = JwtAPIEntreprise::Operation::CreateMagicLink.call(
      params: params,
      current_user: current_user,
    )

    if send_magic_link.success?
      success_message(title: t('.success.title'))
    else
      error_message(title: t('.error.title'))
    end

    redirect_back fallback_location: root_path
  end
end
