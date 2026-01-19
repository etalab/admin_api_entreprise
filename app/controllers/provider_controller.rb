class ProviderController < ApplicationController
  include AuthenticatedUserManagement

  helper_method :current_provider

  layout 'provider'

  protected

  def current_provider
    @current_provider ||= provider_klass.find(params[:provider_uid])
  end

  def user_is_provider?
    redirect_to_root unless current_user.provider_uids.any?
  end

  def user_is_current_provider?
    redirect_to_root unless current_provider&.uid && current_user.provider_uids.include?(current_provider.uid)
  end

  def provider_klass
    Kernel.const_get("API#{namespace.classify}::Provider")
  end
end
