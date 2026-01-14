module EndpointHelper
  def endpoint_status_badge(endpoint)
    "<abbr title=\"#{endpoint_status_title(endpoint)}\" class=\"fr-badge fr-badge--#{endpoint_status_color(endpoint)} fr-mb-2v\">#{endpoint_status_label(endpoint)}</abbr>".html_safe unless endpoint.pending_status.nil?
  end

  def order_by_position_or_status(endpoint1, endpoint2)
    return -1 if endpoint1.pending_status && !endpoint2.pending_status
    return 1 if !endpoint1.pending_status && endpoint2.pending_status

    0
  end

  def endpoint_attribute_keys(endpoint)
    return [] unless endpoint.implemented?

    extract_attribute_keys(endpoint.attributes)
  end

  private

  def extract_attribute_keys(attributes, path_keys = [], path_titles = [])
    return [] unless attributes.is_a?(Hash)

    attributes.flat_map do |key, properties|
      build_attribute_entry(key, properties, path_keys, path_titles)
    end
  end

  def build_attribute_entry(key, properties, path_keys, path_titles)
    current_path_keys = path_keys + [key]
    current_path_titles = path_titles + [properties['title'] || key.humanize]

    result = [{ key: current_path_keys.join('->'), display: current_path_titles.join(' → ') }]
    result + extract_nested_keys(properties, current_path_keys, current_path_titles)
  end

  def extract_nested_keys(properties, path_keys, path_titles)
    nested = nested_properties(properties)
    return [] unless nested

    extract_attribute_keys(nested, path_keys, path_titles)
  end

  def nested_properties(properties)
    return properties['properties'] if properties['type'] == 'object'
    return properties.dig('items', 'properties') if properties['type'] == 'array'

    nil
  end

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
