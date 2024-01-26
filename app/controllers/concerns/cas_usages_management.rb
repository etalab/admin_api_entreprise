module CasUsagesManagement
  def index
    @cas_usages = cas_usage_klass.all
  end

  def show
    @cas_usage = cas_usage_klass.find(params[:uid])
    @other_cas_usages = cas_usage_klass.all - [@cas_usage]
    @active_endpoints = EndpointDecorator.decorate_collection(namespace.classify.constantize::Endpoint.all.reject(&:deprecated))
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  private

  def cas_usage_klass
    namespace.classify.constantize::CasUsage
  end
end
