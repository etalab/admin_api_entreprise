class EndpointDecorator < ApplicationDecorator
  delegate_all

  def cas_usage_icon(cas_usage_name)
    cas_usage_to_icon(cas_usage_name) ||
      cas_usage_to_icon_optional(cas_usage_name) ||
      cas_usage_to_icon_forbidden(cas_usage_name) ||
      '-'
  end

  private

  def cas_usage_to_icon(cas_usage_name)
    cas_usage_icon_tag('fr-icon-checkbox-circle-fill', '#1f8d49') if use_case?(cas_usage_name)
  end

  def cas_usage_to_icon_optional(cas_usage_name)
    cas_usage_icon_tag('fr-icon-checkbox-circle-line', '#1f8d49') if use_case_optional?(cas_usage_name)
  end

  def cas_usage_to_icon_forbidden(cas_usage_name)
    cas_usage_icon_tag('fr-icon-close-circle-line', '#d64d00') if use_case_forbidden?(cas_usage_name)
  end

  def cas_usage_icon_tag(icon_class, color)
    "<span style=\"color:#{color}\" class=\"#{icon_class}\" aria-hidden=\"true\"></span>"
  end
end
