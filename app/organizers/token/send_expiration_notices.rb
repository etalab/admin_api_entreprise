class Token::SendExpirationNotices < ApplicationOrganizer
  organize Token::RetrieveExpiring,
           Token::DeliverExpirationNoticeEmails
end
