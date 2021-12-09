class Admin::ContactsController < AuthenticatedAdminsController
  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @form = ::ContactForm.new(Contact.find(params[:id]))

    if @form.update(update_params)
      success_message(title: t('.success'))
      token = @form.model.authorization_request.jwt_api_entreprise

      redirect_to token_contacts_path(token)
    else
      error_message(title: t('.error'), description: @form.errors.messages)
      @contact = @form.model

      render :edit
    end
  end

  private

  def update_params
    params.require(:contact).permit(:email, :phone_number, :contact_type)
  end
end
