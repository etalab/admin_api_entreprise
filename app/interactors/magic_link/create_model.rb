class MagicLink::CreateModel < ApplicationInteractor
  def call
    context.magic_link = MagicLink.create!(email: context.email)
  end
end
