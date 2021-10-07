class ApplicationController < ActionController::Base
  include UserSessionsHelpers

  layout 'application'

  def error_message(title:, description: nil)
    flash_message(:error, title: title, description: description)
  end

  def success_message(title:, description: nil)
    flash_message(:success, title: title, description: description)
  end

  def info_message(title:, description: nil)
    flash_message(:info, title: title, description: description)
  end

  private

  def flash_message(kind, title:, description:)
    flash[kind] ||= {}
    flash[kind]['title'] = title
    flash[kind]['description'] = description
  end
end
