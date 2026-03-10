class Admin::Tokens::Create < ApplicationOrganizer
  organize Admin::Tokens::ValidateExpiration,
    Admin::Tokens::CreateToken

  after do
    MonitoringService.instance.track('Create token by admin', level: 'info', context: {
      admin_id: context.admin.id,
      token_id: context.token.id,
      datapass_id: context.authorization_request.external_id
    })
  end
end
