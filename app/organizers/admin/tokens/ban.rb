class Admin::Tokens::Ban < ApplicationOrganizer
  organize Admin::Tokens::BanToken,
    Admin::Tokens::SendBanEmail
end
