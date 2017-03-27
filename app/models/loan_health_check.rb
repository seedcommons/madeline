# == Schema Information
#
# Table name: loan_health_checks
#
#  created_at           :datetime         not null
#  has_late_steps       :boolean
#  has_sporadic_updates :boolean
#  id                   :integer          not null, primary key
#  last_log_date        :date
#  missing_contract     :boolean
#  progress_pct         :decimal(, )
#  project_id           :integer
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_loan_health_checks_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_6441c92912  (project_id => projects.id)
#

class LoanHealthCheck < ActiveRecord::Base
  belongs_to :loan, class_name: Project, foreign_key: :project_id

  def recalculate(event_name)
    missing_contract = signed_contract?
    save!
  end

  private

  def signed_contract?
    loan.media.where(kind_value: 'contract').count > 0
  end

  def active?
    status_value == 'active'
  end

  def incomplete_steps?
    timeline_entries.merge(ProjectStep.past_due).count > 0
  end

  def sporadic_loan_updates?
    timeline_entries.merge(ProjectStep.recent).count < [days_old, 30].min
  end

  def progress_pct
    return 0 unless criteria
    criteria.progress_pct
  end

  def health_warnings
    warnings = []
    warnings << :active_without_signed_contract if active? && !signed_contract?
    warnings << :active_without_recent_logs if active? && most_recent_log_date < 30.days.ago
    warnings << :past_due_steps if incomplete_steps?
    warnings << :incomplete_loan_questions if progress_pct < 80
    warnings << :sporadic_loan_updates if sporadic_loan_updates?
    warnings
  end

  def healthy?
    health_warnings.count < 1
  end

  def days_old
    (end_date.beginning_of_day - signing_date.beginning_of_day) / (24 * 60 * 60)
  end

  def most_recent_log_date
    project_logs.maximum(:date) || Time.at(0)
  end
end
