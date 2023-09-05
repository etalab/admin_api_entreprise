module EndpointHelper
  def endpoint_status_badge(endpoint)
    "<p class=\"fr-badge fr-badge--#{endpoint_status_color(endpoint)}\">#{endpoint_status_label(endpoint)}</p>".html_safe unless endpoint.pending_status.nil?
  end

  private

  def endpoint_status_color(endpoint)
    I18n.t("#{endpoint.pending_status}.color")
  end

  def endpoint_status_label(endpoint)
    I18n.t("#{endpoint.pending_status}.label")
  end
end
