require 'mina/rails'
require 'mina/bundler'
require 'mina/git'
require 'colorize'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

ENV['to'] ||= 'sandbox'
%w[sandbox staging production].include?(ENV['to']) || raise("target environment (#{ENV['to']}) not in the list")

print "Deploy to #{ENV['to']}\n".green

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :commit, ENV['commit']
set :application_name, 'admin_apientreprise'
set :domain, ENV['domain']
set :deploy_to, "/var/www/admin_apientreprise_#{ENV['to']}"
set :rails_env, ENV['to']
set :repository, 'git@github.com:etalab/admin_api_entreprise.git'

branch = ENV['branch'] ||
  begin
    case ENV['to']
    when 'production'
      'master'
    when 'staging'
      'master'
    when 'sandbox'
      'develop'
    end
  end

set :branch, branch
ensure!(:branch)

# Optional settings:
set :user, 'deploy'          # Username in the server to SSH to.
set :port, 22           # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push(
  'bin',
  'log',
  'public/system',
  'public/uploads',
  'tmp/pids',
  'tmp/files',
  'tmp/sockets',
  'tmp/cache'
)
set :shared_files, fetch(:shared_files, []).push(
  'config/credentials/sandbox.key',
  'config/credentials/staging.key',
  'config/credentials/production.key',
  'config/database.yml',
  'config/sidekiq.yml',
  'config/master.key',
  'config/initializers/cors.rb',
  "config/environments/#{ENV['to']}.rb"
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  set :rbenv_path, '/usr/local/rbenv'
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :cgu_to_pdf
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        invoke :restart_sidekiq
        invoke :'passenger'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :restart_sidekiq do
  comment 'Restarting Sidekiq (reloads code)'.green
  command %(sudo systemctl restart sidekiq_admin_apientreprise_#{ENV['to']}_1.service)
end

task :passenger do
  comment %{Attempting to start the app through passenger}.green
  command %{
    if (sudo passenger-status | grep admin_apientreprise_#{ENV['to']}) > /dev/null
    then
      passenger-config restart-app /var/www/admin_apientreprise_#{ENV['to']}/current
    else
      echo 'Skipping: no Passenger app found (will be automatically loaded)'
    fi}
end

task :cgu_to_pdf do
  comment 'Generating PDF version of CGU'.green
  command %(pandoc app/views/pages/cgu.html.erb -o public/cgu.pdf --pdf-engine=xelatex)
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
