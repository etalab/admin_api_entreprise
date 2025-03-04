class Provider::DashboardController < ProviderController
  def index
    @providers = provider_klass.filter_by_uid(current_user.provider_uids)

    return unless @providers.size == 1

    redirect_to provider_dashboard_path(provider_uid: @providers.first.uid)
  end

  def show
    @embed_url = nil
  end
end
