module AuthorizationRequestHelper
  def authorization_request_status_badge(authorization_request)
    "<p class=\"fr-badge fr-badge--#{authorization_request_status_color(authorization_request)}\">#{authorization_request_status_label(authorization_request)}</p>".html_safe
  end

  private

  def authorization_request_status_color(authorization_request)
    I18n.t("shared.authorization_requests.status.color.#{authorization_request.status}")
  end

  def authorization_request_status_label(authorization_request)
    I18n.t("shared.authorization_requests.status.label.#{authorization_request.status}")
  end
end
