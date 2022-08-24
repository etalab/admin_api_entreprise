module ActiveLinks
  def active_link_attribute(kind, current_url)
    return unless active_link?(kind, current_url)

    'aria-current="page"'
  end

  def active_link?(kind, current_url)
    case kind
    when 'catalogue'
      Rails.application.routes.recognize_path(current_url)[:controller] == 'endpoints'
    when 'developer'
      current_url.include?('/developpeurs')
    when 'cas_usages'
      current_url.include?('/cas_usages')
    else
      false
    end
  end
end
