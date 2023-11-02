class TokenManipulationFacade
  attr_reader :authorization_request, :token, :user

  def initialize(token, user)
    @authorization_request = token.authorization_request
    @token = token
    @user = user
  end

  def can_ask_for_extension?
    !demandeur? and token.day_left < 90
  end

  def can_show?
    demandeur? || contact_technique?
  end

  def can_prolong?
    demandeur? and token.day_left < 90
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
