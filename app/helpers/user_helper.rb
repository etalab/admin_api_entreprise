# frozen_string_literal: true

module UserHelper
  def full_name_builder(first_name, last_name)
    [first_name, last_name].select(&:present?).join(' ').presence
  end
end
