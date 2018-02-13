namespace :db_seed do
  desc 'Saves a list of roles into the database'
  task roles: :environment do
    pastel = Pastel.new

    operation_result = Role::DBSeed.call
    operation_result[:log].map do |log|
      if log =~ /\ARole created/
        puts pastel.green(log)
      else
        puts pastel.yellow(log)
      end
    end
  end
end
