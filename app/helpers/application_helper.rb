module ApplicationHelper
  def status_to_color(status)
    case status
    when :up
      'success'
    when :has_issues
      'error'
    when :maintenance
      'info'
    else
      'undefined'
    end
  end
end
