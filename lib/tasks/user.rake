namespace :user do
  desc "Transfert all the tokens to the target email (even if account does not exists) - rake user:transfer_account\\['current_email','new_email','namespace'\\] (no space between emails)"
  task :transfer_account, %i[current_owner_email target_user_email namespace] => :environment do |_, args|
    current_owner = User.find_by(email: args.current_owner_email)
    transfer = User::TransferAccount.call(current_owner:, target_user_email: args.target_user_email, authorization_requests: current_owner.authorization_requests.for_api(args.namespace.slice(4..-1)), namespace: args.namespace)

    if transfer.success?
      puts 'Transfer successful'
    else
      puts "Transfer failed: #{transfer.message}"
    end
  end
end
