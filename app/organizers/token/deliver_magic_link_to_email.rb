class Token::DeliverMagicLinkToEmail < ApplicationOrganizer
  organize ValidateEmail,
    Token::CreateMagicLink,
    Token::SendEmailWithMagicLink
end
