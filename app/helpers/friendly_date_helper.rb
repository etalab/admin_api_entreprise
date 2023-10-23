module FriendlyDateHelper
  def friendly_format_from_timestamp(timestamp)
    "#{Time.zone.at(timestamp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end

  def friendly_date_from_timestamp(timestamp)
    Time.zone.at(timestamp).strftime('%d/%m/%Y').to_s
  end
end
