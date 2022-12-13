class MagicLink::ValidateAbsence < ApplicationInteractor
  def call
    context.fail! if MagicLink.unexpired.where(email: context.email).any?
  end
end
