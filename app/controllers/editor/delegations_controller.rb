class Editor::DelegationsController < EditorController
  before_action :ensure_delegations_enabled

  def index
    @editor_tokens = current_editor.editor_tokens.order(created_at: :desc)
    @delegations = current_editor
      .editor_delegations
      .includes(authorization_request: %i[organization demandeur])
      .order(created_at: :desc)
      .page(params[:page])
  end

  private

  def ensure_delegations_enabled
    return if current_editor.delegations_enabled?

    redirect_to editor_authorization_requests_path
  end
end
