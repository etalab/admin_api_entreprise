class EditorController < ApplicationController
  include AuthenticatedUserManagement

  before_action :user_is_editor?
  helper_method :current_editor

  layout 'editor'

  protected

  def current_editor
    @current_editor ||= current_user.editor
  end

  private

  def user_is_editor?
    redirect_to_root unless current_user.editor?
  end

  def namespace
    request.host.split('.').first
  end
end
