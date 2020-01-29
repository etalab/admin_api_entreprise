if File.exists?('csv_dumps/match_account_email.json')
  file = File.read('csv_dumps/match_account_email.json')
  DSEmailHash = JSON.parse(file)['DS']
end

if File.exists?('csv_dumps/match_account_email.json')
  file = File.read('csv_dumps/match_account_email.json')
  SignupEmailHash = JSON.parse(file)['SIGNUP']
end
