# config valid only for current version of Capistrano
lock '3.11.0'

set :application, 'madeline'

# If you have problems deploying, use the below https url instead
set :repo_url, 'https://github.com/sassafrastech/madeline.git'
# set :repo_url, 'git@github.com:sassafrastech/madeline_system.git'

set :tmp_dir, '/home/deploy/tmp'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# Set a different branch OR tag on the fly with `cap <stage> deploy BRANCH=<branch_or_tag>`
set :branch, -> { ENV['BRANCH'] || fetch(:stage) }

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, -> { "/var/www/rails/madeline/#{fetch(:stage)}" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, %w{config/database.yml config/secrets.yml config/scout_apm.yml}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/images public/assets}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/uploads public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Namespace crontab entries
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_environment, -> { fetch(:rails_env) }

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

desc "Write the branch to a .branch file in the release that was deployed"
task :write_branch do
  on release_roles(:all) do
    within release_path do
      execute :echo, "#{fetch(:branch)} > BRANCH"
    end
  end
end

desc "Update the OptionSets"
task :update_option_sets do
  on release_roles(:all) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute(:bundle, :exec, :rails, :runner, 'OptionSetCreator.create_all')
      end
    end
  end
end

after "deploy:updating", "write_branch"
