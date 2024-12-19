class Editor::AuthorizationRequestsController < EditorController
  def index
    @q = current_editor
      .authorization_requests(api: namespace)
      .includes(:active_token, :demandeur)
      .where(
        status: 'validated'
      ).ransack(params[:q])

    @authorization_requests = @q.result(distinct: true).page(params[:page])
  end
end
