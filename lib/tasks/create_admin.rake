task 'create_admin': :environment do
  User.create(
    email: 'admin@entreprise.api.gouv.fr',
    password: 'admin',
    admin: true,
    context: 'Admin',
  )
end
