class ApplicationController < ActionController::Base
  include Pundit::Authorization

  include UserSessionsHelper
  helper UserSessionsHelper

  helper ActiveLinks

  helper_method :namespace

  rescue_from Pundit::NotAuthorizedError do |_|
    error_message(title: t('.error.unauthorize'))
    redirect_current_user_to_homepage
  end

  rescue_from ActiveRecord::RecordNotFound do |_|
    error_message(title: t('.error.record_not_found'))
    if user_signed_in?
      redirect_current_user_to_homepage
    else
      redirect_to_root
    end
  end

  def error_message(title:, description: nil, id: nil)
    flash_message(:error, title:, description:, id:)
  end

  def success_message(title:, description: nil, id: nil)
    flash_message(:success, title:, description:, id:)
  end

  def info_message(title:, description: nil, id: nil)
    flash_message(:info, title:, description:, id:)
  end

  private

  def flash_message(kind, title:, description:, id:)
    flash[kind] ||= {}
    flash[kind]['title'] = title
    flash[kind]['description'] = description
    flash[kind]['id'] = id
  end
end
