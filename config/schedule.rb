every 1.day, at: '3:00' do
  runner 'RecalculateAllLoanHealthJob.perform_later'
end

# runs job at midnight
every '0 0 1 * *' do
  runner 'MonthlyInterestAccrualJob.perform_later'
end
