class ApplicationController < ActionController::Base
  include Pundit::Authorization

  include UserSessionsHelper
  helper UserSessionsHelper

  helper ActiveLinks

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
