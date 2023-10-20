class TokenShowDecorator < ApplicationDecorator
  delegate_all

  def passed_time_as_ratio
    total_duration = exp - created_at.to_i
    time_passed = Time.zone.now.to_i - created_at.to_i

    return 100 if time_passed > total_duration

    time_passed.to_f / total_duration * 100
  end

  def status
    return 'expired' if expired?
    return 'revoked' if blacklisted? || blacklisted_later?

    'active'
  end

  def progress_bar_color
    day_left = (exp - Time.zone.now.to_i) / 86_400
    if day_left < 30
      'red'
    elsif day_left < 90
      'orange'
    else
      'green'
    end
  end
end
