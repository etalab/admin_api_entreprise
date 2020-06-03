task 'create_admin': :environment do
  user_id = Rails.application.credentials.admin_uid
  user_pwd = Rails.application.credentials.admin_password
  User.create(
    id: user_id,
    email: 'admin@entreprise.api.gouv.fr',
    password: user_pwd,
    context: 'Admin',
    confirmed_at: Time.zone.now
  )
end
