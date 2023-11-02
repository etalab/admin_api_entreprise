class TokenManipulationFacade
  attr_reader :authorization_request, :main_token, :user

  def initialize(main_token, user)
    @authorization_request = main_token.authorization_request
    @main_token = main_token
    @user = user
  end

  def can_show?
    demandeur? || contact_technique?
  end

  def can_prolong?
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
