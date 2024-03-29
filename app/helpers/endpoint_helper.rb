module EndpointHelper
  def endpoint_status_badge(endpoint)
    "<abbr title=\"#{endpoint_status_title(endpoint)}\" class=\"fr-badge fr-badge--#{endpoint_status_color(endpoint)} fr-mb-2v\">#{endpoint_status_label(endpoint)}</abbr>".html_safe unless endpoint.pending_status.nil?
  end

  def order_by_position_or_status(endpoint1, endpoint2)
    return -1 if endpoint1.pending_status && !endpoint2.pending_status
    return 1 if !endpoint1.pending_status && endpoint2.pending_status

    0
  end

  private

  def endpoint_status_color(endpoint)
    I18n.t("#{endpoint.pending_status}.color")
  end

  def endpoint_status_title(endpoint)
    I18n.t("#{endpoint.pending_status}.title")
  end

  def endpoint_status_label(endpoint)
    I18n.t("#{endpoint.pending_status}.label")
  end
end
