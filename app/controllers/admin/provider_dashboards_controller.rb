class Admin::ProviderDashboardsController < AdminController
  def index
    @providers = provider_klass.all
  end

  def show
    @provider = provider_klass.find(params[:id])
    @stats_facade = ProviderStatsFacade.new(@provider)

    render 'provider/dashboard/show'
  end

  private

  def provider_klass
    Kernel.const_get("API#{namespace.classify}::Provider")
  end

  def current_provider
    @provider
  end

  helper_method :current_provider
end
