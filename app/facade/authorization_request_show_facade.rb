class AuthorizationRequestShowFacade
  attr_reader :authorization_request, :main_token, :user

  def initialize(authorization_request, main_token, user)
    @authorization_request = authorization_request
    @main_token = main_token
    @user = user
  end

  def can_show_technical_user_modal?
    demandeur? || contact_technique?
  end

  def can_show_extend_token_modal
    demandeur? and main_token.day_left < 90
  end

  private

  def demandeur?
    @authorization_request.demandeur == user
  end

  def contact_technique?
    @authorization_request.contact_technique == user
  end

  def contact_metier?
    @authorization_request.contact_metier == user
  end
end
