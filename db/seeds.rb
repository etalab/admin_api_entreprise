return unless Rails.env.development?

Seeds.new.perform
