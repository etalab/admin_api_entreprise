class ProviderController < ApplicationController
  include AuthenticatedUserManagement

  before_action :user_is_provider?
  helper_method :current_provider

  layout 'provider'

  protected

  def current_provider
    @current_provider ||= provider_klass.find(params[:provider_uid])
  end

  def user_is_provider?
    redirect_to_root unless current_user.provider_uids.any?
  end

  def provider_klass
    Kernel.const_get("API#{namespace.classify}::Provider")
  end

  def namespace
    request.host.split('.').first
  end
end
