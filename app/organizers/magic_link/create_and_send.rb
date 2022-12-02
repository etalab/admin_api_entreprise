class MagicLink::CreateAndSend < ApplicationOrganizer
  organize MagicLink::ExtractUserOrContact,
    MagicLink::CreateModel,
    MagicLink::DeliverEmail
end
