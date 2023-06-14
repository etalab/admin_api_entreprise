class OpenBureauDate
  include DateAndTime::Calculations

  def next_date
    return Time.zone.today if open_bureau_today?

    next_tuesday = Time.zone.today.next_occurring(:tuesday)

    if first_or_third_in_month?(next_tuesday)
      next_tuesday
    else
      next_tuesday + 7
    end
  end

  private

  def open_bureau_today?
    today = Time.zone.today

    today.tuesday? && first_or_third_in_month?(today) && before_open_bureau_time?
  end

  def before_open_bureau_time?
    Time.zone.now < '11:00 am'.in_time_zone(Time.zone)
  end

  def first_or_third_in_month?(tuesday)
    first_day_month = tuesday.at_beginning_of_month

    return true if first_day_month.tuesday?

    first_tuesday_after_beginning_month = first_day_month.next_occurring(:tuesday)

    first_tuesday_after_beginning_month == tuesday || (first_tuesday_after_beginning_month + 14) == tuesday
  end
end
