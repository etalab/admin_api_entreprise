module DelegationsManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_authorization_request
  end

  def create
    result = EditorDelegation::Create.call(
      authorization_request: @authorization_request,
      editor_id: params[:editor_id]
    )

    if result.success?
      success_message(title: t('.success.title'))
    else
      error_message(title: result.message)
    end

    redirect_to authorization_request_path(@authorization_request)
  end

  def destroy
    result = EditorDelegation::Revoke.call(
      authorization_request: @authorization_request,
      delegation_id: params[:id]
    )

    if result.success?
      success_message(title: t('.success.title'))
    else
      error_message(title: result.message)
    end

    redirect_to authorization_request_path(@authorization_request)
  end

  private

  def set_authorization_request
    @authorization_request = current_user
      .authorization_requests
      .where(api:)
      .find(params[:authorization_request_id])
  end

  def api
    namespace.slice(4..-1)
  end
end
