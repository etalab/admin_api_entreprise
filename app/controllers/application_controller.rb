class ApplicationController < ActionController::Base
  include UserSessionsHelper
  helper UserSessionsHelper

  helper ActiveLinks

  layout 'application'

  def error_message(title:, description: nil)
    flash_message(:error, title:, description:)
  end

  def success_message(title:, description: nil)
    flash_message(:success, title:, description:)
  end

  def info_message(title:, description: nil)
    flash_message(:info, title:, description:)
  end

  private

  def flash_message(kind, title:, description:)
    flash[kind] ||= {}
    flash[kind]['title'] = title
    flash[kind]['description'] = description
  end
end
