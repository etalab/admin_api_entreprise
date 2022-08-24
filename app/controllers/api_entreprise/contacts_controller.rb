class APIEntreprise::ContactsController < APIEntreprise::AuthenticatedUsersController
  def index
    @token = Token.includes(:contacts).find(params[:id])

    if access_to_contacts?
      @contacts = @token.contacts
    else
      error_message(title: t('.unauthorized'))

      redirect_current_user_to_homepage
    end
  end

  private

  def access_to_contacts?
    current_user == @token.user
  end
end
