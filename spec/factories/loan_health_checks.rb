FactoryGirl.define do
  factory :loan_health_check do
    loan
    missing_contract false
    progress_pct "9.99"
    last_log_date "2017-03-26"
    has_late_steps false
    has_sporadic_updates false
  end
end
