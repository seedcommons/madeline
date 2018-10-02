set :output, 'log/cron.log'

env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']

every 1.day, at: '3am' do
  runner 'RecalculateAllLoanHealthJob.perform_later'
end

# runs job at 2am every start of month
# https://github.com/javan/whenever/issues/13 for more details
every 1.month, at: 'start of the month at 2am' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end

# built in script job type is not updated for rails 4 and higher
job_type :script, 'cd :path && RAILS_ENV=:environment bundle exec bin/:task :output'
every :reboot do
  script 'delayed_job restart'
end
