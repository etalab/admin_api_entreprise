namespace :db_seed do
  desc 'Saves a list of scopes into the database'
  task scopes: :environment do
    pastel = Pastel.new

    operation_result = Scope::Operation::DBSeed.call
    operation_result[:log].map do |log|
      if log =~ /\AScope created/
        puts pastel.green(log)
      else
        puts pastel.yellow(log)
      end
    end
  end
end
