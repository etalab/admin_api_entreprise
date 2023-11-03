class TokenPolicy < ApplicationPolicy
  attr_reader :user, :token

  def initialize(user, token)
    @user = user
    @token = token
  end

  def ask_for_extension?
    !demandeur? and token.day_left < 90
  end

  def show?
    demandeur? || contact_technique?
  end

  def prolong?
    demandeur? and token.day_left < 90
  end

  private

  def demandeur?
    @token.authorization_request.demandeur == user
  end

  def contact_technique?
    @token.authorization_request.contact_technique == user
  end

  def contact_metier?
    @token.authorization_request.contact_metier == user
  end
end
