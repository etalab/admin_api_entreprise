module ActiveLinks
  def active_link_attribute(kind, current_path)
    return unless active_link?(kind, current_path)

    'aria-current="page"'
  end

  def active_link?(kind, current_path)
    case kind
    when 'catalogue'
      Rails.application.routes.recognize_path(current_path)[:controller] == 'endpoints'
    when 'developer'
      current_path.starts_with?('/developpeurs')
    when 'cas_usages'
      current_path.starts_with?('/cas_usages')
    else
      false
    end
  end
end
