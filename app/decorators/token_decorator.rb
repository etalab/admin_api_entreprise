class TokenDecorator < ApplicationDecorator
  delegate_all

  def day_left
    @day_left ||= (end_timestamp - Time.zone.now.to_i) / 86_400
  end

  def passed_time_as_ratio
    total_duration = end_timestamp - created_at.to_i
    time_passed = Time.zone.now.to_i - created_at.to_i

    return 100 if time_passed > total_duration

    time_passed.to_f / total_duration * 100
  end

  def status
    return 'expired' if expired?
    return 'revoked' if blacklisted?
    return 'revoked_later' if blacklisted_later?
    return 'new_token' if access_logs.empty?

    'active'
  end

  def progress_bar_color
    if day_left < 30
      'red'
    elsif day_left < 90
      'orange'
    else
      'green'
    end
  end
end
