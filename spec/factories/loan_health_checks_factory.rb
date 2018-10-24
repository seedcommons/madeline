# == Schema Information
#
# Table name: loan_health_checks
#
#  created_at           :datetime         not null
#  has_late_steps       :boolean
#  has_sporadic_updates :boolean
#  id                   :integer          not null, primary key
#  last_log_date        :date
#  loan_id              :integer          not null
#  missing_contract     :boolean
#  progress_pct         :decimal(, )
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_loan_health_checks_on_loan_id  (loan_id)
#
# Foreign Keys
#
#  fk_rails_...  (loan_id => projects.id)
#

FactoryBot.define do
  factory :loan_health_check do
    loan
    missing_contract false
    progress_pct "9.99"
    last_log_date "2017-03-26"
    has_late_steps false
    has_sporadic_updates false
  end
end
