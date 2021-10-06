module FriendlyDateHelper
  def friendly_format_from_timestamp(timestamp)
    "#{Time.zone.at(timestamp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end
end
