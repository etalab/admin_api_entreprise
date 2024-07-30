class APIParticulier::ReportersController < APIParticulier::AuthenticatedUsersController
  def show
    if reporters_config.exclude?(reporter_group) || reporters_config[reporter_group].exclude?(current_user.email)
      redirect_to_root
      return
    end

    @datapasses_for_group_url = MetabaseEmbedService.new(487, { group: params[:id] }).url
  end

  private

  def reporter_group
    params[:id].to_sym
  end

  def reporters_config
    Rails.application.credentials.api_particulier_reporters
  end
end
