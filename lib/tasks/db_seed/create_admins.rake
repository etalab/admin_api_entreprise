namespace :db_seed do
  desc 'Create administrators'
  task create_admins: :environment do
    admin_emails = Rails.application.credentials.admin_accounts
    admin_emails.each do |acc_email|
      user = User.find_or_initialize_by_email(acc_email)
      user.update(admin: true, context: 'Administrateur API Entreprise')
    end
  end
end
