class APIEntreprise::ContactsController < APIEntreprise::AuthenticatedUsersController
  def index
    @token = Token.find(params[:id])

    if access_to_contacts?
      @contacts = @token.contacts_no_demandeur
    else
      error_message(title: t('.unauthorized'))

      redirect_current_user_to_homepage
    end
  end

  private

  def access_to_contacts?
    @token.demandeur == current_user
  end
end
