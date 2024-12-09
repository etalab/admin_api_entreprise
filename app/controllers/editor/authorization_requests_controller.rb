class Editor::AuthorizationRequestsController < EditorController
  def index
    @authorization_requests = current_editor
      .authorization_requests(api: namespace)
      .includes(:active_token)
      .where(
        status: 'validated'
      ).page(params[:page])
  end
end
