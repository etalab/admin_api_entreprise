class Admin::UsersController < AdminController
  def index
    downcase_params if params[:q].present?
    @q = User.includes(:editor).ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
    @editors = Editor.all
    @providers = provider_klass.all
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_update_params)
      success_message(title: "Utilisateur #{@user.email} a bien été modifié")

      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def impersonate
    user = User.find(params[:id])

    impersonate_user(user)

    redirect_to authorization_requests_path
  end

  def stop_impersonating
    stop_impersonating_user

    redirect_to admin_users_path
  end

  private

  def user_params
    params.expect(user: [:editor_id, { provider_uids: [] }])
  end

  def user_update_params
    update_params = user_params
    update_params[:provider_uids] = [] unless params[:user].key?(:provider_uids)
    update_params
  end

  def provider_klass
    Kernel.const_get("API#{namespace.classify}::Provider")
  end

  def downcase_params
    params[:q][:email_or_authorization_requests_siret_or_authorization_requests_external_id_eq] = params[:q][:email_or_authorization_requests_siret_or_authorization_requests_external_id_eq].downcase if params[:q][:email_or_authorization_requests_siret_or_authorization_requests_external_id_eq].present?
  end
end
