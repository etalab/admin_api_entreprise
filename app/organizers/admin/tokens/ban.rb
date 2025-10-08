class Admin::Tokens::Ban < ApplicationOrganizer
  organize Admin::Tokens::BanToken,
    Admin::Tokens::SendBanEmail

  after do
    MonitoringService.instance.track('Ban token by admin', level: 'info', context: {
      admin_id: context.admin.id,
      token_id: context.token.id,
      datapass_id: context.token.authorization_request.external_id
    })
  end
end
