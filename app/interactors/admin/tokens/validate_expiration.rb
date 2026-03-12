class Admin::Tokens::ValidateExpiration < ApplicationInteractor
  def call
    context.exp = parse_expiration

    validate_not_in_past
    validate_not_exceeding_max
  end

  private

  def parse_expiration
    if context.exp_date.present?
      Time.zone.parse(context.exp_date).end_of_day.to_i
    else
      18.months.from_now.to_i
    end
  end

  def validate_not_in_past
    context.fail!(message: "La date d'expiration ne peut pas être dans le passé") if context.exp <= Time.zone.now.to_i
  end

  def validate_not_exceeding_max
    context.fail!(message: "La date d'expiration ne peut pas dépasser 18 mois") if context.exp > 18.months.from_now.end_of_day.to_i
  end
end
