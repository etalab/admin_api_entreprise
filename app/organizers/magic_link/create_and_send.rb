class MagicLink::CreateAndSend < ApplicationOrganizer
  organize MagicLink::ValidateAbsence,
    MagicLink::ExtractUserOrContact,
    MagicLink::CreateModel,
    MagicLink::DeliverEmail
end
