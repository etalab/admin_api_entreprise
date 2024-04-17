class EndpointDecorator < ApplicationDecorator
  delegate_all

  def cas_usage_icon(cas_usage)
    cas_usage_to_icon(cas_usage) ||
      cas_usage_to_icon_optional(cas_usage) ||
      cas_usage_to_icon_forbidden(cas_usage) ||
      '-'
  end

  private

  def cas_usage_to_icon(cas_usage)
    cas_usage_icon_tag('fr-icon-checkbox-circle-fill', '#1f8d49') if use_case?(cas_usage)
  end

  def cas_usage_to_icon_optional(cas_usage)
    cas_usage_icon_tag('fr-icon-checkbox-circle-line', '#1f8d49') if use_case_optional?(cas_usage)
  end

  def cas_usage_to_icon_forbidden(cas_usage)
    cas_usage_icon_tag('fr-icon-close-circle-line', '#d64d00') if use_case_forbidden?(cas_usage)
  end

  def cas_usage_icon_tag(icon_class, color)
    "<span style=\"color:#{color}\" class=\"#{icon_class}\" aria-hidden=\"true\"></span>"
  end

  def use_case?(cas_usage)
    use_cases.map(&:uid).include?(cas_usage.uid)
  end

  def use_case_optional?(cas_usage)
    use_cases_optional.map(&:uid).include?(cas_usage.uid)
  end

  def use_case_forbidden?(cas_usage)
    use_cases_forbidden.map(&:uid).include?(cas_usage.uid)
  end
end
