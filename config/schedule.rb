every 1.day, at: '3:00' do
  runner 'RecalculateAllLoanHealthJob.perform_later'
end

# runs job at 2am every start of month
# https://github.com/javan/whenever/issues/13 for more details
every 1.month, at: 'start of the month at 2am' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end
