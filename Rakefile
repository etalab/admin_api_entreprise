# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

wd1 = 'ns3162821.ip-51-91-107.eu'
wd2 = 'ns3189474.ip-135-125-108.eu'

domains = [wd1, wd2]

task :setup do
  domains.each do |domain|
    sh "mina setup domain=#{domain}"
  end
end

task :deploy do
  domains.each do |domain|
    sh "mina deploy domain=#{domain}"
  end
end
