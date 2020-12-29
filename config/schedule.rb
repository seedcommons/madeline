set :output, 'log/cron.log'

job_type :rbenv_rake, %Q{ eval "$(rbenv init -)"; cd :path && bundle exec rake :task --silent :output }

env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']

every 1.day, at: '3am' do
  runner 'RecalculateAllLoanHealthJob.perform_later'
end

case @environment
when 'production'
  every 1.day, at: '2am' do
    rake "madeline:enqueue_update_loans_task"
  end
when 'staging'
  every 1.day, at: '2am' do
    rbenv_rake "madeline:enqueue_update_loans_task"
  end
end

# built in script job type is not updated for rails 4 and higher
job_type :script, 'cd :path && RAILS_ENV=:environment bundle exec bin/:task :output'
every :reboot do
  script 'sidekiq'
end
