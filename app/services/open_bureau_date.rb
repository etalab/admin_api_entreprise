class OpenBureauDate
  include DateAndTime::Calculations

  def next_date
    return Time.zone.today if open_bureau_today?

    next_tuesday = Time.zone.today.next_occurring(:tuesday)

    return next_tuesday if first_or_third_tuesday_in_month?(next_tuesday)

    next_tuesday.next_occurring(:tuesday)
  end

  private

  def open_bureau_today?
    today = Time.zone.today

    today.tuesday? && first_or_third_tuesday_in_month?(today) && before_open_bureau_time?
  end

  def before_open_bureau_time?
    Time.zone.now < '11:00 am'.in_time_zone(Time.zone)
  end

  def first_or_third_tuesday_in_month?(date)
    return false unless date.tuesday?

    first_of_month = date.beginning_of_month

    first_tuesday = first_of_month + ((2 - first_of_month.wday) % 7)

    third_tuesday = first_tuesday.next_occurring(:tuesday).next_occurring(:tuesday)

    date == first_tuesday || date == third_tuesday
  end
end
