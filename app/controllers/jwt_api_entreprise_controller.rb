class JwtAPIEntrepriseController < AuthenticatedUsersController
  skip_before_action :authenticate_user!, only: [:show_magic_link]

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

  def show_magic_link
    retrieve_jwt = JwtAPIEntreprise::Operation::RetrieveFromMagicLink.call(params: params)

    if retrieve_jwt.success?
      @tokens = [retrieve_jwt[:jwt]]
      render :index, layout: 'application'
    else
      error_message(title: t('.error.title'))
      redirect_to login_path
    end
  end
end
