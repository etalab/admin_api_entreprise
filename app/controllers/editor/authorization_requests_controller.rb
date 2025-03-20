require 'csv'

class Editor::AuthorizationRequestsController < EditorController
  include ExternalUrlHelper

  def index
    @q = current_editor
      .authorization_requests(api: namespace)
      .includes(:active_token, :demandeur)
      .where(
        status: 'validated'
      ).ransack(params[:q])

    @authorization_requests = @q.result(distinct: true)

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@authorization_requests),
          filename: "habilitations_#{Time.zone.today}.csv",
          type: 'text/csv'
      end
    end
  end

  private

  def generate_csv(authorization_requests)
    CSV.generate(headers: true) do |csv|
      csv << %w[datapass_id datapass_url intitule token_expiration siret demandeur_email]

      authorization_requests.where(status: 'validated').each do |authorization_request|
        csv << generate_line(authorization_request)
      end
    end
  end

  def generate_line(authorization_request)
    [
      authorization_request.external_id,
      datapass_v2_public_authorization_request_url(authorization_request),
      authorization_request.intitule,
      authorization_request.token&.exp.present? ? Time.zone.at(authorization_request.token.exp).to_datetime : nil,
      authorization_request.siret,
      authorization_request.demandeur&.email
    ]
  end
end
