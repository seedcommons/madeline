every 1.day, at: '3:00' do
  runner "RecalculateAllLoanHealthJob.perform_later"
end
