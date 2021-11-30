class Admin::TokensController < AuthenticatedAdminsController
  before_action :retrieve_token, except: :index

  def index
    @tokens = JwtAPIEntreprise.all
  end

  def show
    @user  = @token.user

    redirect_to admin_user_path(@user)
  end

  def blacklist
    update_token(blacklisted: true)
  end

  def archive
    update_token(archived: true)
  end

  private

  def retrieve_token
    @token = JwtAPIEntreprise.find_by_id(params[:id])
  end

  def update_token(updated_attrs)
    if @token.update(updated_attrs)
      @user = @token.user

      # i18n-tasks-use t('admin.tokens.archive.alert')
      # i18n-tasks-use t('admin.tokens.blacklist.alert')
      info_message(title: t(".#{params[:action]}.alert", token_subject: @token.displayed_subject))
      redirect_to admin_user_path(@user)
    end
  end
end
