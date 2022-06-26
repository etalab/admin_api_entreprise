namespace :user do
  desc "Transfert all the tokens to the target email (even if account does not exists) - rake user:transfer_account\\['current_email','new_email'\\] (no space between emails)"
  task :transfer_account, %i[current_owner_email target_user_email] => :environment do |_, args|
    current_owner = User.find_by(email: args.current_owner_email)
    transfer = User::TransferAccount.call(current_owner:, target_user_email: args.target_user_email)

    if transfer.success?
      puts 'Transfer successful'
    else
      puts "Transfer failed: #{transfer.message}"
    end
  end
end
