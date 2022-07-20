class OpenBureauDate
  include DateAndTime::Calculations

  def next_date
    next_tuesday = Time.zone.today.next_occurring(:tuesday)

    if first_or_third_in_month?(next_tuesday)
      next_tuesday
    else
      next_tuesday + 7
    end
  end

  private

  def first_or_third_in_month?(next_tuesday)
    first_day_month = next_tuesday.at_beginning_of_month

    first_tuesday_after_beginning_month = first_day_month.next_occurring(:tuesday)

    first_tuesday_after_beginning_month == next_tuesday || (first_tuesday_after_beginning_month + 14) == next_tuesday
  end
end
