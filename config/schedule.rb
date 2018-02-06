every 1.day, at: '3:00' do
  runner 'RecalculateAllLoanHealthJob.perform_later'
end

# whenever doesn't support the last day of the month bit
# this hack will run the job 10 minutes to midnight on the last day of the month

every '50 23 31 1,3,5,7,8,10,12 *' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end

every '50 23 30 4,6,9,11 *' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end

every '50 23 28,29 2 *' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end
